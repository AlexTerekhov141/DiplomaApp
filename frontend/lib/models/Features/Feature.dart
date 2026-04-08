import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class Feature {
  Feature({
    required this.name,
    required this.icon,
    required this.route
  });
  String name;
  IconData icon;
  PageRouteInfo route;
}