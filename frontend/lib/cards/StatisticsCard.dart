import 'package:categorize_app/bloc/PhotosBloc/bloc.dart';
import 'package:categorize_app/bloc/PhotosBloc/states.dart';
import 'package:categorize_app/models/Folders/Folder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/Tags.dart';


class StatisticsCard extends StatelessWidget {
  const StatisticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    const Tags tags = Tags();
    final Folder folders = Folder(id: '', name: '', photosCount: 0);
    return BlocBuilder<PhotosBloc, PhotosState>(
      builder: (BuildContext context, PhotosState state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _StatItem(label: 'Photos', value: state.photos.length),
            _StatItem(label: 'Folders', value: tags.amount),
            _StatItem(label: 'Tags', value: folders.amount),
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