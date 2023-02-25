import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';

class Album extends Equatable {
  const Album({
    required this.id,
    required this.name,
    required this.artists,
    required this.tracks,
    required this.source,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? imageUrl;
  final List<String> artists;
  final List<Track> tracks;
  final MusicSource source;

  Album copyWith({
    String? id,
    String? name,
    String? imageUrl,
    List<String>? artists,
    List<Track>? tracks,
    MusicSource? source,
  }) {
    return Album(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      artists: artists ?? this.artists,
      tracks: tracks ?? this.tracks,
      source: source ?? this.source,
    );
  }

  @override
  List<Object?> get props => [id, name, imageUrl, artists, tracks, source];
}
