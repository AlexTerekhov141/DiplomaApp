import 'package:bloc/bloc.dart';

import 'event.dart';
import 'state.dart';

class TagsBlocBloc extends Bloc<TagsBlocEvent, TagsBlocState> {
  TagsBlocBloc() : super(TagsBlocState().init());

  @override
  Stream<TagsBlocState> mapEventToState(TagsBlocEvent event) async* {
    if (event is InitEvent) {
      yield await init();
    }
  }

  Future<TagsBlocState> init() async {
    return state.clone();
  }
}
