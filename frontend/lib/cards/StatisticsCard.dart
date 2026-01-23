import 'package:categorize_app/bloc/StatisticsBloc/bloc.dart';
import 'package:categorize_app/bloc/StatisticsBloc/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class StatisticsCard extends StatelessWidget {
  const StatisticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      builder: (BuildContext context, StatisticsState state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _StatItem(label: 'Photos', value: state.photosCount),
            _StatItem(label: 'Folders', value: state.foldersCount),
            _StatItem(label: 'Tags', value: state.tagsCount),
          ],
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}