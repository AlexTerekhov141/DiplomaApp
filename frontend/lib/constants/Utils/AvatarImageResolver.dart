import 'dart:io';

import 'package:flutter/material.dart';

ImageProvider resolveAvatarImage(String imagePath) {
  const AssetImage fallback = AssetImage('assets/profiles/profile.png');

  if (imagePath.isEmpty) {
    return fallback;
  }

  if (imagePath.startsWith('http:') || imagePath.startsWith('https://')) {
    return NetworkImage(imagePath);
  }

  final File file = File(imagePath);
  if (file.existsSync()) {
    return FileImage(file);
  }

  if (imagePath.startsWith('assets/')) {
    return AssetImage(imagePath);
  }

  return fallback;
}