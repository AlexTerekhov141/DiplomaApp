import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  void _updateViewData(SettingsViewData value) {
    setState(() {
      _viewData = value;
    });
  }

  void _showCacheClearedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image cache cleared'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                  onClearCacheTap: _showCacheClearedMessage,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}