import 'package:categorize_app/bloc/tagsbloc/bloc.dart';
import 'package:categorize_app/bloc/tagsbloc/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class TagsFilterList extends StatelessWidget {
  const TagsFilterList({
    super.key,
    required this.visibleTags,
    required this.selectedTags,
  });

  final List<String> visibleTags;
  final List<String> selectedTags;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
          vertical: 2,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: visibleTags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, int index) {
          final String tag = visibleTags[index];
          final bool isSelected = selectedTags.contains(tag);

          return FilterChip(
            label: Text(tag),
            selected: isSelected,
            onSelected: (_) {
              context.read<TagsBloc>().add(
                isSelected
                    ? TagUnselected(tag: tag)
                    : TagSelected(tag: tag),
              );
            },
          );
        },
      ),
    );
  }
}