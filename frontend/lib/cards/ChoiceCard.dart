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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(header!, style:  Theme.of(context).textTheme.bodySmall,),
        ),
        Card(
          elevation: 0,
          color: Colors.transparent,
          child: Column(
            children: List.generate(titles.length, (int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                          style: TextStyle(fontSize: 15, color: colors[index]),
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
