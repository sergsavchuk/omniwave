// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../music_source.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MusicSourceAdapter extends TypeAdapter<MusicSource> {
  @override
  final int typeId = 4;

  @override
  MusicSource read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MusicSource.spotify;
      case 1:
        return MusicSource.youtube;
      default:
        return MusicSource.spotify;
    }
  }

  @override
  void write(BinaryWriter writer, MusicSource obj) {
    switch (obj) {
      case MusicSource.spotify:
        writer.writeByte(0);
        break;
      case MusicSource.youtube:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
