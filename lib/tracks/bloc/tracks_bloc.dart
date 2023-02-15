import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'tracks_event.dart';
part 'tracks_state.dart';

class TracksBloc extends Bloc<TracksEvent, TracksState> {
  TracksBloc() : super(const TracksState()) {
    on<TracksEvent>((event, emit) {
      // TODO(sergsavchuk): implement event handler
    });
  }
}
