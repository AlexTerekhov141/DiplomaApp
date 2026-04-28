import 'package:equatable/equatable.dart';

abstract class PhotoRoastEvent extends Equatable {
  const PhotoRoastEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class PhotoRoastQualityGroupsRequested extends PhotoRoastEvent {
  const PhotoRoastQualityGroupsRequested();
}

class PhotoRoastErrorCleared extends PhotoRoastEvent {
  const PhotoRoastErrorCleared();
}
