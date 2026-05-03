import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../models/CleanUp/CleanupSeggestionStatus.dart';
import '../../../models/CleanUp/CleanupSuggestion.dart';
import '../../../models/CleanUp/CleanupSuggestionType.dart';
import 'data/MarkersOcr.dart';

class OcrCleanupAnalyzer {
  OcrCleanupAnalyzer({
    required this.textRecognizer,
    DateTime? now,
    this.thumbnailSize = const ThumbnailSize(1024, 1024),
    this.thumbnailQuality = 90,
  }) : _now = now ?? DateTime.now();

  final TextRecognizer textRecognizer;
  final DateTime _now;
  final ThumbnailSize thumbnailSize;
  final int thumbnailQuality;
  Future<bool>? _ocrSupportedFuture;

  static const MethodChannel _deviceChannel =
      MethodChannel('categorize_app/device');
  //static const int _minAndroidSdkForOcr = 34;

  Future<CleanupSuggestion?> analyze(AssetEntity asset) async {
    if (asset.type != AssetType.image) {
      return null;
    }

    /*if (!await _isOcrSupportedOnDevice()) {
      return null;
    }*/

    final String text = await recognizeText(asset);
    if (text.trim().isEmpty) {
      return null;
    }

    final List<DateTime> dates = _extractDates(text);
    debugPrint('OCR DATES: $dates');
    if (dates.isEmpty) {
      return null;
    }

    final DateTime? expiredDate = _findExpiredDate(dates);
    debugPrint('OCR EXPIRED DATE: $expiredDate');
    if (expiredDate == null) {
      return null;
    }
    final bool looksLikeAnnouncement = _looksLikeExpiredAnnouncement(text);
    debugPrint('OCR LOOKS ANNOUNCEMENT: $looksLikeAnnouncement');
    if (!looksLikeAnnouncement) {
      return null;
    }

    if (!_looksLikeExpiredAnnouncement(text)) {
      return null;
    }

    return CleanupSuggestion(
      assetId: asset.id,
      type: CleanupSuggestionType.expired,
      status: CleanupSuggestionStatus.suggested,
      score: 0.82,
      reason: 'Announcement date has already passed',
      createdAt: _now,
      updatedAt: _now,
      features: <String, dynamic>{
        'ocr_text': text,
        'expired_date': expiredDate.toIso8601String(),
        'detected_dates': dates
            .map((DateTime date) => date.toIso8601String())
            .toList(),
      },
    );
  }

  Future<String> recognizeText(AssetEntity asset) async {
    final File? file = await asset.file;

    if (file == null || !await file.exists()) {
      return '';
    }

    final InputImage inputImage = InputImage.fromFile(file);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    debugPrint('OCR ASSET: ${asset.id} ${asset.title} ${asset.createDateTime}');
    debugPrint('OCR FILE: ${file.path}');
    debugPrint('OCR TEXT: ${recognizedText.text}');

    return recognizedText.text;

    return recognizedText.text;
  }

  /*Future<bool> _isOcrSupportedOnDevice() {
    _ocrSupportedFuture ??= _loadOcrSupportedOnDevice();
    return _ocrSupportedFuture!;
  }*/

  /*Future<bool> _loadOcrSupportedOnDevice() async {
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      final int? sdkInt = await _deviceChannel.invokeMethod<int>(
        'androidSdkInt',
      );
      return (sdkInt ?? 0) >= _minAndroidSdkForOcr;
    } catch (_) {
      return false;
    }
  }*/

  Future<File?> _createThumbnailFile(AssetEntity asset) async {
    final Uint8List? bytes = await asset.thumbnailDataWithSize(
      thumbnailSize,
      quality: thumbnailQuality,
    );
    if (bytes == null || bytes.isEmpty) {
      return null;
    }

    final Directory tempDirectory = await getTemporaryDirectory();
    final String safeId = asset.id.hashCode.toUnsigned(32).toString();
    final File file = File(
      '${tempDirectory.path}${Platform.pathSeparator}cleanup_ocr_$safeId.jpg',
    );

    return file.writeAsBytes(bytes, flush: false);
  }

  DateTime? _findExpiredDate(List<DateTime> dates) {
    final DateTime today = DateTime(_now.year, _now.month, _now.day);

    for (final DateTime date in dates) {
      if (date.isBefore(today)) {
        return date;
      }
    }

    return null;
  }

  bool _looksLikeExpiredAnnouncement(String text) {
    final String normalized = text.toLowerCase();
    return markers.any((String marker) {
      return normalized.contains(marker.toLowerCase());
    });
  }


  List<DateTime> _extractDates(String text) {
    final List<DateTime> dates = <DateTime>[];
    final String normalized = text.toLowerCase();
    final RegExp numericDateRegex = RegExp(
      r'\b(\d{1,2})[./-](\d{1,2})(?:[./-](\d{2,4}))?\b',
    );

    for (final RegExpMatch match in numericDateRegex.allMatches(normalized)) {
      final int? day = int.tryParse(match.group(1) ?? '');
      final int? month = int.tryParse(match.group(2) ?? '');
      final int? year = int.tryParse(match.group(3) ?? '');

      _addDateIfValid(dates, day: day, month: month, year: year);
    }

    final String monthPattern = _monthNumbers.keys.join('|');
    final RegExp monthNameDateRegex = RegExp(
      '(\\d{1,2})\\s+($monthPattern)(?:\\s+(\\d{2,4}))?',
      unicode: true,
    );

    for (final RegExpMatch match in monthNameDateRegex.allMatches(normalized)) {
      final int? day = int.tryParse(match.group(1) ?? '');
      final int? month = _monthNumbers[match.group(2)];
      final int? year = int.tryParse(match.group(3) ?? '');

      _addDateIfValid(dates, day: day, month: month, year: year);
    }

    return dates;
  }

  void _addDateIfValid(
    List<DateTime> dates, {
    required int? day,
    required int? month,
    required int? year,
  }) {
    if (day == null || month == null) {
      return;
    }

    int resolvedYear = year ?? _now.year;
    if (resolvedYear < 100) {
      resolvedYear += 2000;
    }

    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return;
    }

    try {
      dates.add(DateTime(resolvedYear, month, day));
    } catch (_) {}
  }

  static const Map<String, int> _monthNumbers = <String, int>{
    'январь': 1,
    'января': 1,
    'февраль': 2,
    'февраля': 2,
    'март': 3,
    'марта': 3,
    'апрель': 4,
    'апреля': 4,
    'April': 4,
    'april': 4,
    'май': 5,
    'мая': 5,
    'июнь': 6,
    'июня': 6,
    'июль': 7,
    'июля': 7,
    'август': 8,
    'августа': 8,
    'сентябрь': 9,
    'сентября': 9,
    'октябрь': 10,
    'октября': 10,
    'ноябрь': 11,
    'ноября': 11,
    'декабрь': 12,
    'декабря': 12,
  };
}
