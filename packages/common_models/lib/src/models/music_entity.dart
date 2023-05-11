import 'package:common_models/common_models.dart';
import 'package:equatable/equatable.dart';

abstract class MusicEntity extends Equatable {
  const MusicEntity({
    required this.id,
    required this.name,
    required this.artists,
    required this.source,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String? imageUrl;
  final List<String> artists;
  final MusicSource source;
}
