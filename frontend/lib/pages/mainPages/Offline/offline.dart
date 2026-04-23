import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Routes/routes.gr.dart';
import 'package:categorize_app/models/Processing_mode.dart';
import 'package:categorize_app/repository/AppSettingsRepository/AppSettingsRepository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';


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
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => _showModeDialog(
                  title: 'Offline Mode',
                  content: 'Use local processing on this device.',
                  mode: ProcessingMode.offline,
                ),
                child: const Text('Offline'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showModeDialog(
                  title: 'Online Mode',
                  content: 'Use server processing without opening profile.',
                  mode: ProcessingMode.online,
                ),
                child: const Text('Online'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showModeDialog({
    required String title,
    required String content,
    required ProcessingMode mode,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: const Text('Continue'),
            onPressed: () async {
              await _settings.setProcessingMode(mode);
              if (!mounted) {
                return;
              }
              Navigator.of(dialogContext).pop();
              context.router.replace(const AppRoute());
            },
          ),
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
        );
      },
    );
  }
}
