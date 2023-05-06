part of 'track_collection_bloc.dart';

class TrackCollectionState extends Equatable {
  const TrackCollectionState({this.scrollPosition = 0});

  final double scrollPosition;

  @override
  List<Object> get props => [scrollPosition];
}
