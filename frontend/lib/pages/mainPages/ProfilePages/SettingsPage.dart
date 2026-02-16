import 'package:auto_route/annotations.dart';
import 'package:categorize_app/Widgets/ResponsiveFrame.dart';
import 'package:categorize_app/bloc/themebloc/events.dart';
import 'package:categorize_app/bloc/themebloc/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/themebloc/bloc.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool uploadOnlyWifi = true;
  bool autoSyncOnStart = true;
  bool backgroundSync = false;
  bool compactDensity = false;
  String selectedUploadQuality = 'High';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ResponsiveFrame(
        maxWidth: 860,
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (BuildContext context, ThemeState state) {
            return ListView(
              children: <Widget>[
                _Group(
                  title: 'Appearance',
                  subtitle: 'Theme and layout',
                  children: <Widget>[
                    _DropdownTile(
                      icon: Icons.palette_outlined,
                      title: 'Theme',
                      subtitle: 'Choose app appearance',
                      value: _themeModeLabel(state.themeMode),
                      values: const <String>['System', 'Light', 'Dark'],
                      onChanged: (String value) {
                        context.read<ThemeBloc>().add(
                          SetThemeModeEvent(_themeModeValueFromLabel(value)),
                        );
                      },
                    ),
                    _DropdownTile(
                      icon: Icons.grid_view_rounded,
                      title: 'Gallery grid size',
                      subtitle: 'Photo tile size in gallery',
                      value: _gridSizeLabel(state.gridSize),
                      values: const <String>['Small', 'Medium', 'Large'],
                      onChanged: (String value) {
                        context.read<ThemeBloc>().add(
                          SetGridSizeEvent(_gridSizeValueFromLabel(value)),
                        );
                      },
                    ),
                    _SwitchTile(
                      icon: Icons.density_medium_outlined,
                      title: 'Compact interface density',
                      subtitle: 'Reduce spacing between elements',
                      value: compactDensity,
                      onChanged: (bool value) {
                        setState(() {
                          compactDensity = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _Group(
                  title: 'Photos',
                  subtitle: 'Upload and sync preferences',
                  children: <Widget>[
                    _DropdownTile(
                      icon: Icons.high_quality_outlined,
                      title: 'Upload quality',
                      subtitle: 'Balance quality and network usage',
                      value: selectedUploadQuality,
                      values: const <String>['Original', 'High', 'Medium'],
                      onChanged: (String value) {
                        setState(() {
                          selectedUploadQuality = value;
                        });
                      },
                    ),
                    _SwitchTile(
                      icon: Icons.wifi_outlined,
                      title: 'Upload only on Wi-Fi',
                      subtitle: 'Recommended for large files',
                      value: uploadOnlyWifi,
                      onChanged: (bool value) {
                        setState(() {
                          uploadOnlyWifi = value;
                        });
                      },
                    ),
                    _SwitchTile(
                      icon: Icons.sync_rounded,
                      title: 'Auto-sync on app start',
                      subtitle: 'Keep gallery up to date',
                      value: autoSyncOnStart,
                      onChanged: (bool value) {
                        setState(() {
                          autoSyncOnStart = value;
                        });
                      },
                    ),
                    _SwitchTile(
                      icon: Icons.update_outlined,
                      title: 'Background sync',
                      subtitle: 'Run sync outside active screen',
                      value: backgroundSync,
                      onChanged: (bool value) {
                        setState(() {
                          backgroundSync = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _Group(
                  title: 'Storage & cache',
                  subtitle: 'Local files and cleanup',
                  children: <Widget>[
                    const _InfoTile(
                      icon: Icons.storage_outlined,
                      title: 'Image cache size',
                      subtitle: 'Estimated size: 128 MB',
                    ),
                    _ActionTile(
                      icon: Icons.cleaning_services_outlined,
                      title: 'Clear image cache',
                      subtitle: 'Remove cached thumbnails and previews',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Image cache cleared'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

String _themeModeLabel(ThemeMode themeMode) {
  switch (themeMode) {
    case ThemeMode.light:
      return 'Light';
    case ThemeMode.dark:
      return 'Dark';
    case ThemeMode.system:
      return 'System';
  }
}

ThemeModeValue _themeModeValueFromLabel(String label) {
  switch (label) {
    case 'Light':
      return ThemeModeValue.light;
    case 'Dark':
      return ThemeModeValue.dark;
    default:
      return ThemeModeValue.system;
  }
}

String _gridSizeLabel(GalleryGridSize gridSize) {
  switch (gridSize) {
    case GalleryGridSize.small:
      return 'Small';
    case GalleryGridSize.medium:
      return 'Medium';
    case GalleryGridSize.large:
      return 'Large';
  }
}

GridSizeValue _gridSizeValueFromLabel(String label) {
  switch (label) {
    case 'Small':
      return GridSizeValue.small;
    case 'Large':
      return GridSizeValue.large;
    default:
      return GridSizeValue.medium;
  }
}



class _Group extends StatelessWidget {
  const _Group({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            ..._withDividers(children),
          ],
        ),
      ),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  const _DropdownTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _TileIcon(icon: icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        onChanged: (String? value) {
          if (value != null) {
            onChanged(value);
          }
        },
        items: values
            .map(
              (String item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)),
            )
            .toList(),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: _TileIcon(icon: icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _TileIcon(icon: icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _TileIcon(icon: icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _TileIcon extends StatelessWidget {
  const _TileIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: theme.colorScheme.primary),
    );
  }
}

List<Widget> _withDividers(List<Widget> items) {
  if (items.isEmpty) {
    return const <Widget>[];
  }
  final List<Widget> output = <Widget>[];
  for (int i = 0; i < items.length; i++) {
    output.add(items[i]);
    if (i != items.length - 1) {
      output.add(const Divider(height: 1));
    }
  }
  return output;
}
