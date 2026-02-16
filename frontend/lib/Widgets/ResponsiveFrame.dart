import 'package:flutter/material.dart';

class ResponsiveFrame extends StatelessWidget {
  const ResponsiveFrame({
    super.key,
    required this.child,
    this.maxWidth = 1100,
    this.mobilePadding = const EdgeInsets.all(16),
    this.desktopPadding = const EdgeInsets.all(24),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets mobilePadding;
  final EdgeInsets desktopPadding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isDesktopWidth = constraints.maxWidth >= 900;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: isDesktopWidth ? desktopPadding : mobilePadding,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}
