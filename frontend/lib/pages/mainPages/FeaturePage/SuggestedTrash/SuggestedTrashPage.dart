import 'package:auto_route/annotations.dart';
import 'package:categorize_app/bloc/CleanupBloc/cleanupbloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../Widgets/ResponsiveFrame.dart';
import '../../../../models/CleanUp/CleanupSuggestionGroup.dart';
import 'Widgets/CleanupTile.dart';

@RoutePage()
class Suggestedtrashpage extends StatefulWidget {
  const Suggestedtrashpage({super.key});

  @override
  State<Suggestedtrashpage> createState() => _SuggestedtrashpageState();
}

class _SuggestedtrashpageState extends State<Suggestedtrashpage> {

  @override
  void initState() {
    super.initState();
    context.read<CleanupBloc>().add(LoadCleanupGroups());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveFrame(
        maxWidth: 1200,
        mobilePadding: EdgeInsets.zero,
        desktopPadding: EdgeInsets.zero,
        child: Column(
          children: [
            const SuggestedTrashProgressHeader(),
            Expanded(
                child: BlocBuilder<CleanupBloc, CleanupState>(
                  builder: (BuildContext context, CleanupState state) {
                    if (state.error != null) {
                      return SuggestedTrashMessageState(
                        icon: Icons.error_outline,
                        title: 'Analysis stopped',
                        subtitle: state.error!,
                      );
                    }
                    if(state.isLoading && state.groups.isEmpty){
                      return const Center(child: CircularProgressIndicator());
                    }
                    if(state.groups.isEmpty && state.isAnalyzing){
                      return SuggestedTrashAnalyzingState(state: state);
                    }
                    if(state.groups.isEmpty && !state.isAnalyzing){
                      return const SuggestedTrashEmptyState();
                    }
                    if(state.groups.isNotEmpty){
                      return SuggestedTrashGroupsGrid(groups: state.groups);
                    }
                    return const SuggestedTrashMessageState(
                      icon: Icons.search_off,
                      title: 'No groups found',
                      subtitle: 'Start analysis to find photos that may be cleaned up.',
                    );
                  },

                ))
          ],
        ),
      )
    );
  }
}

class SuggestedTrashProgressHeader extends StatelessWidget{
  const SuggestedTrashProgressHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CleanupBloc, CleanupState>(
      builder: (BuildContext context, CleanupState state) {
        final bool hasSuggestions = state.groups.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (state.message != null) ...<Widget>[
                Text(
                  state.message!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
              ],
              if (state.isAnalyzing) ...<Widget>[
                LinearProgressIndicator(
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(20),
                ),
                const SizedBox(height: 8),
                Text(
                  'Processed in this run: ${state.processedCount}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: state.isAnalyzing
                          ? null
                          : () {
                              context.read<CleanupBloc>().add(StartCleanupAnalysis());
                            },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Start'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: state.isAnalyzing ? () {
                              context.read<CleanupBloc>().add(StopCleanupAnalysis());
                            }
                          : null,
                      icon: const Icon(Icons.stop_rounded),
                      label: const Text('Stop'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: hasSuggestions && !state.isAnalyzing ? () {
                              context.read<CleanupBloc>().add(MoveAllCleanupSuggestionsToTrash());
                            }
                          : null,
                      icon: const Icon(Icons.delete_sweep_outlined),
                      label: const Text('Trash'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

}

class SuggestedTrashGroupsGrid extends StatelessWidget{
  SuggestedTrashGroupsGrid({super.key, required this.groups});
  final List<CleanupSuggestionGroup> groups;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: groups.length,
      itemBuilder: (_, int index) {
        return Cleanuptile(group: groups[index]);
      },
    );
  }
}

class SuggestedTrashAnalyzingState extends StatelessWidget {
  const SuggestedTrashAnalyzingState({
    super.key,
    required this.state,
  });

  final CleanupState state;

  @override
  Widget build(BuildContext context) {
    return SuggestedTrashMessageState(
      icon: Icons.auto_awesome_motion_outlined,
      title: 'Analyzing gallery',
      subtitle: 'Processed ${state.processedCount} photos. Suggestions will appear here as soon as they are found.',
    );
  }
}

class SuggestedTrashEmptyState extends StatelessWidget{
  const SuggestedTrashEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const SuggestedTrashMessageState(
      icon: Icons.cleaning_services_outlined,
      title: 'No suggestions yet',
      subtitle: 'Press Start to scan photos for screenshots, duplicates, bad quality images, and expired announcements.',
    );
  }

}

class SuggestedTrashMessageState extends StatelessWidget {
  const SuggestedTrashMessageState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
