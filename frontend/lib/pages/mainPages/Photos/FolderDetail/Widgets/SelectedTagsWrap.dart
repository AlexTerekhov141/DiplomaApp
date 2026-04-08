import 'package:categorize_app/bloc/tagsbloc/bloc.dart';
import 'package:categorize_app/bloc/tagsbloc/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class SelectedTagsWrap extends StatelessWidget {
  const SelectedTagsWrap({
    super.key,
    required this.selectedTags,
  });

  final List<String> selectedTags;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedTags.map((String tag) {
            return InputChip(
              label: Text(tag),
              selected: true,
              onSelected: (_) {
                context.read<TagsBloc>().add(
                  TagUnselected(tag: tag),
                );
              },
              onDeleted: () {
                context.read<TagsBloc>().add(
                  TagUnselected(tag: tag),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}