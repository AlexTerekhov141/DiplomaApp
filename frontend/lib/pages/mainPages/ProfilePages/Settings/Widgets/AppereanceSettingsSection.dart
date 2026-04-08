import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../bloc/themebloc/bloc.dart';
import '../../../../../bloc/themebloc/events.dart';
import '../../../../../bloc/themebloc/states.dart';
import '../../../../../constants/Utils/SettingsMapper.dart';
import '../../../../../models/Settings/SettingsViewData.dart';
import 'SettingsDropDownTile.dart';
import 'SettingsGroup.dart';
import 'SettingsSwitchTile.dart';


class AppearanceSettingsSection extends StatelessWidget {
  const AppearanceSettingsSection({
    super.key,
    required this.themeState,
    required this.viewData,
    required this.onViewDataChanged,
  });

  final ThemeState themeState;
  final SettingsViewData viewData;
  final ValueChanged<SettingsViewData> onViewDataChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: 'Appearance',
      subtitle: 'Theme and layout',
      children: <Widget>[
        SettingsDropdownTile(
          icon: Icons.palette_outlined,
          title: 'Theme',
          subtitle: 'Choose app appearance',
          value: themeModeLabel(themeState.themeMode),
          values: const <String>['System', 'Light', 'Dark'],
          onChanged: (String value) {
            context.read<ThemeBloc>().add(
              SetThemeModeEvent(themeModeValueFromLabel(value)),
            );
          },
        ),
        SettingsDropdownTile(
          icon: Icons.grid_view_rounded,
          title: 'Gallery grid size',
          subtitle: 'Photo tile size in gallery',
          value: gridSizeLabel(themeState.gridSize),
          values: const <String>['Small', 'Medium', 'Large'],
          onChanged: (String value) {
            context.read<ThemeBloc>().add(
              SetGridSizeEvent(gridSizeValueFromLabel(value)),
            );
          },
        ),
        SettingsSwitchTile(
          icon: Icons.density_medium_outlined,
          title: 'Compact interface density',
          subtitle: 'Reduce spacing between elements',
          value: viewData.compactDensity,
          onChanged: (bool value) {
            onViewDataChanged(
              viewData.copyWith(compactDensity: value),
            );
          },
        ),
      ],
    );
  }
}