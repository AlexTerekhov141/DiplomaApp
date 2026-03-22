import 'package:flutter/material.dart';

class SlideData {
  const SlideData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.image
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Image image;
}
