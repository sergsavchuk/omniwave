import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'track_collection_event.dart';

part 'track_collection_state.dart';

class TrackCollectionBloc
    extends Bloc<TrackCollectionEvent, TrackCollectionState> {
  TrackCollectionBloc() : super(const TrackCollectionState()) {
    on<TrackCollectionEvent>((event, emit) {
      // TODO(sergsavchuk): implement event handler
    });
  }
}
