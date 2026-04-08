import 'package:categorize_app/bloc/tagsbloc/bloc.dart';
import 'package:categorize_app/bloc/tagsbloc/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class FolderSearchBar extends StatelessWidget {
  const FolderSearchBar({
    super.key,
    required this.searchQuery,
    required this.hasFilters,
  });

  final String searchQuery;
  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
      child: TextField(
        onChanged: (String value) {
          context.read<TagsBloc>().add(
            SearchQueryChanged(query: value),
          );
        },
        decoration: InputDecoration(
          hintText: 'Search by tag',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: hasFilters
              ? IconButton(
            onPressed: () {
              context.read<TagsBloc>().add(ClearFilters());
            },
            icon: const Icon(Icons.clear),
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}