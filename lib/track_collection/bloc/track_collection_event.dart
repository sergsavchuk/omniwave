part of 'track_collection_bloc.dart';

abstract class TrackCollectionEvent extends Equatable {
  const TrackCollectionEvent();
}

class TrackCollectionScrollPositionChanged extends TrackCollectionEvent {
  const TrackCollectionScrollPositionChanged(this.scrollPosition);

  final double scrollPosition;

  @override
  List<Object?> get props => [scrollPosition];
}
