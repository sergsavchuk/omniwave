import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'playlists_event.dart';
part 'playlists_state.dart';

class PlaylistsBloc extends Bloc<PlaylistsEvent, PlaylistsState> {
  PlaylistsBloc() : super(const PlaylistsState()) {
    on<PlaylistsEvent>((event, emit) {
      // TODO(sergsavchuk): implement event handler
    });
  }
}
