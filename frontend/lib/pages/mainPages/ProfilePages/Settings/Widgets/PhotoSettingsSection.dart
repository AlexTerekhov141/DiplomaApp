import 'package:flutter/material.dart';

import '../../../../../models/Settings/SettingsViewData.dart';
import 'SettingsDropDownTile.dart';
import 'SettingsGroup.dart';
import 'SettingsSwitchTile.dart';


class PhotoSettingsSection extends StatelessWidget {
  const PhotoSettingsSection({
    super.key,
    required this.viewData,
    required this.onViewDataChanged,
  });

  final SettingsViewData viewData;
  final ValueChanged<SettingsViewData> onViewDataChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: 'Photos',
      subtitle: 'Upload and sync preferences',
      children: <Widget>[
        SettingsDropdownTile(
          icon: Icons.high_quality_outlined,
          title: 'Upload quality',
          subtitle: 'Balance quality and network usage',
          value: viewData.selectedUploadQuality,
          values: const <String>['Original', 'High', 'Medium'],
          onChanged: (String value) {
            onViewDataChanged(
              viewData.copyWith(selectedUploadQuality: value),
            );
          },
        ),
        SettingsSwitchTile(
          icon: Icons.wifi_outlined,
          title: 'Upload only on Wi-Fi',
          subtitle: 'Recommended for large files',
          value: viewData.uploadOnlyWifi,
          onChanged: (bool value) {
            onViewDataChanged(
              viewData.copyWith(uploadOnlyWifi: value),
            );
          },
        ),
        SettingsSwitchTile(
          icon: Icons.sync_rounded,
          title: 'Auto-sync on app start',
          subtitle: 'Keep gallery up to date',
          value: viewData.autoSyncOnStart,
          onChanged: (bool value) {
            onViewDataChanged(
              viewData.copyWith(autoSyncOnStart: value),
            );
          },
        ),
        SettingsSwitchTile(
          icon: Icons.update_outlined,
          title: 'Background sync',
          subtitle: 'Run sync outside active screen',
          value: viewData.backgroundSync,
          onChanged: (bool value) {
            onViewDataChanged(
              viewData.copyWith(backgroundSync: value),
            );
          },
        ),
      ],
    );
  }
}