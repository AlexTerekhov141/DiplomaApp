import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ThemeState extends Equatable {
  const ThemeState(this.themeData, this.isLight);
  final ThemeData themeData;
  final bool isLight;

  @override
  List<Object?> get props => <Object?>[themeData, isLight];
}
