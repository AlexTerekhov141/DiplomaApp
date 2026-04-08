import 'package:flutter/material.dart';

import '../../../models/SlideData.dart';

const List<SlideData> onboardingSlides = <SlideData>[
  SlideData(
    title: 'Smart photo organization',
    subtitle:
    'Group photos automatically so the gallery stays clear without manual sorting.',
    icon: Icons.auto_awesome_rounded,
    image: Image(image: AssetImage('assets/onboarding/1.jpg')),
  ),
  SlideData(
    title: 'AI-based grouping',
    subtitle:
    'Categories and tags are generated in background while you continue using the app.',
    icon: Icons.hub_rounded,
    image: Image(image: AssetImage('assets/onboarding/2.jpg')),
  ),
  SlideData(
    title: 'Cleaner gallery',
    subtitle:
    'Start managing your photos with folders that stay updated automatically.',
    icon: Icons.photo_library_rounded,
    image: Image(image: AssetImage('assets/onboarding/3.jpg')),
  ),
];