import 'dart:typed_data';

import 'package:equatable/equatable.dart';

abstract class PhotoRoastEvent extends Equatable {
  const PhotoRoastEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class PhotoRoastImageLoaded extends PhotoRoastEvent {
  const PhotoRoastImageLoaded(this.bytes);

  final Uint8List bytes;

  @override
  List<Object?> get props => <Object?>[bytes];
}

class PhotoRoastAnalyzeRequested extends PhotoRoastEvent {
  const PhotoRoastAnalyzeRequested();
}

class PhotoRoastResetRequested extends PhotoRoastEvent {
  const PhotoRoastResetRequested();
}

class PhotoRoastErrorCleared extends PhotoRoastEvent {
  const PhotoRoastErrorCleared();
}
