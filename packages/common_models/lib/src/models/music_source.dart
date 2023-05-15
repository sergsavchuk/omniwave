import 'package:hive/hive.dart';

part 'generated/music_source.g.dart';

@HiveType(typeId: 4)
enum MusicSource {
  @HiveField(0)
  spotify,
  @HiveField(1)
  youtube,
}
