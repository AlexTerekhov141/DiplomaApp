import 'dart:io';

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../Widgets/ResponsiveFrame.dart';
import '../../../../bloc/themebloc/bloc.dart';
import '../../../../bloc/themebloc/states.dart';
import '../../../../models/Settings/SettingsViewData.dart';
import 'Widgets/AppereanceSettingsSection.dart';
import 'Widgets/PhotoSettingsSection.dart';
import 'Widgets/StorageSettingsSection.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SettingsViewData _viewData = SettingsViewData.initial();
  String _cacheSizeText = 'Calculating...';
  bool _isClearingCache = false;

  @override
  void initState() {
    super.initState();
    _refreshCacheSize();
  }

  void _updateViewData(SettingsViewData value) {
    setState(() {
      _viewData = value;
    });
  }

  Future<void> _refreshCacheSize() async {
    final int memoryCacheBytes =
        PaintingBinding.instance.imageCache.currentSizeBytes;

    final Directory tempDir = await getTemporaryDirectory();
    int tempFilesBytes = 0;

    if (await tempDir.exists()) {
      await for (final FileSystemEntity entity
          in tempDir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          tempFilesBytes += await entity.length();
        }
      }
    }

    final int totalBytes = memoryCacheBytes + tempFilesBytes;

    if (!mounted) {
      return;
    }

    setState(() {
      _cacheSizeText = _formatBytes(totalBytes);
    });
  }

  Future<void> _clearImageCache() async {
    if (_isClearingCache) {
      return;
    }

    setState(() {
      _isClearingCache = true;
    });

    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      await DefaultCacheManager().emptyCache();

      final Directory tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await for (final FileSystemEntity entity
            in tempDir.list(recursive: false, followLinks: false)) {
          try {
            await entity.delete(recursive: true);
          } catch (_) {}
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image cache cleared'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isClearingCache = false;
        });
      }
      await _refreshCacheSize();
    }
  }

  String _formatBytes(int bytes) {
    const List<String> units = <String>['B', 'KB', 'MB', 'GB'];
    double size = bytes.toDouble();
    int unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    final int precision = size < 10 && unitIndex > 0 ? 1 : 0;
    return '${size.toStringAsFixed(precision)} ${units[unitIndex]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ResponsiveFrame(
        maxWidth: 860,
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (BuildContext context, ThemeState themeState) {
            return ListView(
              children: <Widget>[
                AppearanceSettingsSection(
                  themeState: themeState,
                  viewData: _viewData,
                  onViewDataChanged: _updateViewData,
                ),
                const SizedBox(height: 12),
                PhotoSettingsSection(
                  viewData: _viewData,
                  onViewDataChanged: _updateViewData,
                ),
                const SizedBox(height: 12),
                StorageSettingsSection(
                  onClearCacheTap: _clearImageCache,
                  cacheSizeText: _cacheSizeText,
                  isClearing: _isClearingCache,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
