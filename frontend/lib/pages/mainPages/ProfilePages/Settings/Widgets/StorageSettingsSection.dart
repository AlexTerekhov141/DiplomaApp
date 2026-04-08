import 'package:flutter/material.dart';

import 'SettingsActionTile.dart';
import 'SettingsGroup.dart';
import 'SettingsInfoTile.dart';



class StorageSettingsSection extends StatelessWidget {
  const StorageSettingsSection({
    super.key,
    required this.onClearCacheTap,
  });

  final VoidCallback onClearCacheTap;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: 'Storage & cache',
      subtitle: 'Local files and cleanup',
      children: <Widget>[
        const SettingsInfoTile(
          icon: Icons.storage_outlined,
          title: 'Image cache size',
          subtitle: 'Estimated size: 128 MB',
        ),
        SettingsActionTile(
          icon: Icons.cleaning_services_outlined,
          title: 'Clear image cache',
          subtitle: 'Remove cached thumbnails and previews',
          onTap: onClearCacheTap,
        ),
      ],
    );
  }
}