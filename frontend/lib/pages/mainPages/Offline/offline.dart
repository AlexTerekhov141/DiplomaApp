import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Routes/routes.gr.dart';
import 'package:categorize_app/bloc/AuthBloc/authbloc.dart';
import 'package:categorize_app/models/Processing_mode.dart';
import 'package:categorize_app/repository/AppSettingsRepository/AppSettingsRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../constants/AppConstantsModels/Modes.dart';
import '../../../constants/colors.dart';
import '../../../models/Mode.dart';
import 'Widgets/OfflineModeButton.dart';

@RoutePage()
class AppMode extends StatefulWidget {
  const AppMode({super.key});

  @override
  State<AppMode> createState() => _AppModeState();
}

class _AppModeState extends State<AppMode> {
  late final AppSettingsRepository _settings;

  @override
  void initState() {
    super.initState();
    _settings = GetIt.I<AppSettingsRepository>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'How should we process your photos?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose online processing or keep everything on this device.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 28),
                ModeButton(
                  title: 'Offline',
                  subtitle: 'Use local processing on this device.',
                  icon: Icons.phone_android_rounded,
                  color: Green.c500,
                  onTap: () => _showModeDialog(
                    mode: modes[1],
                    processingMode: ProcessingMode.offline,
                    icon: Icons.phone_android_rounded,
                    color: Green.c500,
                  ),
                ),
                const SizedBox(height: 16),
                ModeButton(
                  title: 'Online',
                  subtitle: 'Use server processing without opening profile.',
                  icon: Icons.cloud_done_rounded,
                  color: Blue.c500,
                  onTap: () => _showModeDialog(
                    mode: modes[0],
                    processingMode: ProcessingMode.online,
                    icon: Icons.cloud_done_rounded,
                    color: Blue.c500,
                  ),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }

  Future<void> _showModeDialog({
    required Mode mode,
    required ProcessingMode processingMode,
    required IconData icon,
    required Color color,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: <Widget>[
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(mode.title),
            ],
          ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(mode.description),
                  const SizedBox(height: 18),
                  const _DialogSectionTitle(
                    title: 'What you get',
                    icon: Icons.check_circle_outline_rounded,
                    color: Green.c500,
                  ),
                  ...mode.pros.map(
                    (String text) => _DialogPoint(
                      text: text,
                      icon: Icons.check_rounded,
                      color: Green.c500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _DialogSectionTitle(
                    title: 'Please note',
                    icon: Icons.info_outline_rounded,
                    color: Red.c700,
                  ),
                  ...mode.cons.map(
                    (String text) => _DialogPoint(
                      text: text,
                      icon: Icons.info_outline_rounded,
                      color: Red.c700,
                    ),
                  ),
                ],
              ),
            ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            FilledButton(
              child: const Text('Conutinue'),
              onPressed: () async {
                await _settings.setProcessingMode(processingMode);
                if (!mounted) {
                  return;
                }
                context.read<AuthBloc>().add(
                      AuthProfileUserChoiceUpdate(processingMode: processingMode),
                    );
                Navigator.of(dialogContext).pop();
                context.router.replace(AppRoute());
              },
            ),
          ],
        );
      },
    );
  }
}

class _DialogSectionTitle extends StatelessWidget {
  const _DialogSectionTitle({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

class _DialogPoint extends StatelessWidget {
  const _DialogPoint({
    required this.text,
    required this.icon,
    required this.color,
  });

  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
