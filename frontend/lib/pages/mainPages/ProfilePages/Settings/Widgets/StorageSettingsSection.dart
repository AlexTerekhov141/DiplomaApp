import 'package:flutter/material.dart';

import 'SettingsActionTile.dart';
import 'SettingsGroup.dart';
import 'SettingsInfoTile.dart';



class StorageSettingsSection extends StatelessWidget {
  const StorageSettingsSection({
    super.key,
    required this.onClearCacheTap,
    required this.cacheSizeText,
    required this.isClearing,
  });

  final String cacheSizeText;
  final bool isClearing;
  final Future<void> Function() onClearCacheTap;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: 'Storage & cache',
      subtitle: 'Local files and cleanup',
      children: <Widget>[
        SettingsInfoTile(
          icon: Icons.storage_outlined,
          title: 'Image cache size',
          subtitle: cacheSizeText,
        ),
        SettingsActionTile(
          icon: Icons.cleaning_services_outlined,
          title: 'Clear image cache',
          subtitle: isClearing ? 'Clearing...' : 'Clear',
          onTap: () {
            onClearCacheTap();
          },
        ),
      ],
    );
  }
}
