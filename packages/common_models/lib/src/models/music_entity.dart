import 'package:common_models/common_models.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

abstract class MusicEntity extends Equatable {
  const MusicEntity({
    required this.id,
    required this.name,
    required this.artists,
    required this.source,
    required this.imageUrl,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? imageUrl;
  @HiveField(3)
  final List<String> artists;
  @HiveField(4)
  final MusicSource source;
}
