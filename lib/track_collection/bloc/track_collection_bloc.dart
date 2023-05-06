import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'track_collection_event.dart';

part 'track_collection_state.dart';

class TrackCollectionBloc
    extends Bloc<TrackCollectionEvent, TrackCollectionState> {
  TrackCollectionBloc() : super(const TrackCollectionState()) {
    on<TrackCollectionScrollPositionChanged>(_scrollPositionChanged);
  }

  FutureOr<void> _scrollPositionChanged(
    TrackCollectionScrollPositionChanged event,
    Emitter<TrackCollectionState> emit,
  ) {
    if (event.scrollPosition != state.scrollPosition) {
      emit(TrackCollectionState(scrollPosition: event.scrollPosition));
    }
  }
}
