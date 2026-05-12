import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'OfflinePredictionsStorage.dart';

class SqfliteOfflinePredictionsStorage implements OfflinePredictionsStorage {
  static const String _databaseName = 'offline_predictions.db';
  static const String _tableName = 'offline_predictions';
  static const int _databaseVersion = 1;
  static const int _maxSqlVariables = 900;

  Database? _database;

  Future<Database> get _db async {
    final Database? current = _database;
    if (current != null) {
      return current;
    }

    final Database opened = await _openDatabase();
    _database = opened;
    return opened;
  }

  Future<Database> _openDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String databasePath = p.join(databasesPath, _databaseName);

    return openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            asset_id TEXT PRIMARY KEY,
            label TEXT NOT NULL,
            confidence REAL NOT NULL,
            processed INTEGER NOT NULL,
            tags_json TEXT NOT NULL,
            model_version TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_offline_predictions_processed
          ON $_tableName(processed)
        ''');

        await db.execute('''
          CREATE INDEX idx_offline_predictions_model_version
          ON $_tableName(model_version)
        ''');

        await db.execute('''
          CREATE INDEX idx_offline_predictions_label
          ON $_tableName(label)
        ''');
      },
    );
  }

  @override
  Future<Map<String, dynamic>?> getPrediction(String assetId) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      _tableName,
      where: 'asset_id = ?',
      whereArgs: <Object?>[assetId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }
    return _rowToPrediction(rows.first);
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getPredictionsByIds(
    Iterable<String> assetIds,
  ) async {
    final List<String> ids = assetIds.toSet().toList();
    if (ids.isEmpty) {
      return <String, Map<String, dynamic>>{};
    }

    final Database db = await _db;
    final Map<String, Map<String, dynamic>> result =
        <String, Map<String, dynamic>>{};

    for (final List<String> chunk in _chunks(ids, _maxSqlVariables)) {
      final String placeholders = List<String>.filled(
        chunk.length,
        '?',
      ).join(',');
      final List<Map<String, Object?>> rows = await db.query(
        _tableName,
        where: 'asset_id IN ($placeholders)',
        whereArgs: chunk,
      );

      for (final Map<String, Object?> row in rows) {
        final String assetId = row['asset_id'].toString();
        result[assetId] = _rowToPrediction(row);
      }
    }

    return result;
  }

  @override
  Future<void> upsertPrediction(
    String assetId,
    Map<String, dynamic> prediction,
  ) async {
    await upsertPredictions(
      <String, Map<String, dynamic>>{assetId: prediction},
    );
  }

  @override
  Future<void> upsertPredictions(
    Map<String, Map<String, dynamic>> predictions,
  ) async {
    if (predictions.isEmpty) {
      return;
    }

    final Database db = await _db;
    final Batch batch = db.batch();
    predictions.forEach((String assetId, Map<String, dynamic> prediction) {
      batch.insert(
        _tableName,
        _predictionToRow(assetId, prediction),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit(noResult: true);
  }

  @override
  Future<void> deleteMissingAssets(Set<String> existingAssetIds) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      _tableName,
      columns: <String>['asset_id'],
    );

    final List<String> staleIds = rows
        .map((Map<String, Object?> row) => row['asset_id'].toString())
        .where((String assetId) => !existingAssetIds.contains(assetId))
        .toList();

    if (staleIds.isEmpty) {
      return;
    }

    final Batch batch = db.batch();
    for (final List<String> chunk in _chunks(staleIds, _maxSqlVariables)) {
      final String placeholders = List<String>.filled(
        chunk.length,
        '?',
      ).join(',');
      batch.delete(
        _tableName,
        where: 'asset_id IN ($placeholders)',
        whereArgs: chunk,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<int> countProcessed(String modelVersion) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM $_tableName
      WHERE processed = 1 AND model_version = ?
      ''',
      <Object?>[modelVersion],
    );

    return Sqflite.firstIntValue(rows) ?? 0;
  }

  @override
  Future<void> clear() async {
    final Database db = await _db;
    await db.delete(_tableName);
  }

  Map<String, Object?> _predictionToRow(
    String assetId,
    Map<String, dynamic> prediction,
  ) {
    final List<dynamic> tags = prediction['tags'] as List<dynamic>? ??
        <dynamic>[(prediction['label'] ?? 'uncategorized').toString()];

    return <String, Object?>{
      'asset_id': assetId,
      'label': (prediction['label'] ?? 'uncategorized').toString(),
      'confidence': (prediction['confidence'] as num?)?.toDouble() ?? 0.0,
      'processed': ((prediction['processed'] as bool?) ?? false) ? 1 : 0,
      'tags_json': jsonEncode(tags.map((dynamic e) => e.toString()).toList()),
      'model_version': (prediction['model_version'] ?? '').toString(),
      'updated_at':
          (prediction['updated_at'] ?? DateTime.now().toIso8601String())
              .toString(),
    };
  }

  Map<String, dynamic> _rowToPrediction(Map<String, Object?> row) {
    final String tagsJson = (row['tags_json'] ?? '[]').toString();
    final List<String> tags = _decodeTags(tagsJson);

    return <String, dynamic>{
      'label': (row['label'] ?? 'uncategorized').toString(),
      'confidence': (row['confidence'] as num?)?.toDouble() ?? 0.0,
      'processed': ((row['processed'] as num?)?.toInt() ?? 0) == 1,
      'tags': tags,
      'model_version': (row['model_version'] ?? '').toString(),
      'updated_at': (row['updated_at'] ?? '').toString(),
    };
  }

  List<String> _decodeTags(String tagsJson) {
    try {
      final dynamic decoded = jsonDecode(tagsJson);
      if (decoded is List<dynamic>) {
        return decoded.map((dynamic e) => e.toString()).toList();
      }
    } catch (_) {}

    return <String>['uncategorized'];
  }

  Iterable<List<T>> _chunks<T>(List<T> items, int size) sync* {
    for (int start = 0; start < items.length; start += size) {
      final int end = start + size > items.length ? items.length : start + size;
      yield items.sublist(start, end);
    }
  }
}
