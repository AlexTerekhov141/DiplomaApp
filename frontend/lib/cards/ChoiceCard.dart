import 'package:flutter/material.dart';


class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.titles,
    required this.icons,
    required this.colors,
    required this.onTapList,
    this.header,
  });

  final List<String> titles;
  final List<IconData> icons;
  final List<Color> colors;
  final List<VoidCallback> onTapList;
  final String? header;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (header != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              header!,
              style: theme.textTheme.labelMedium,
            ),
          ),
        Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide.none
          ),
          elevation: 0,
          color: Colors.transparent,
          child: Column(
            children: List.generate(titles.length, (int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerLow,
                    foregroundColor: theme.colorScheme.onSurface,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: onTapList[index],
                  child: Row(
                    children: <Widget>[
                      Icon(icons[index], size: 20, color: colors[index]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          titles[index],
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colors[index],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        )
      ],
    );
  }
}
