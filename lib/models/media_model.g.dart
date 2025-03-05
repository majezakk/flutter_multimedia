// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaModelAdapter extends TypeAdapter<MediaModel> {
  @override
  final int typeId = 1;

  @override
  MediaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaModel(
      id: fields[0] as String,
      mediaType: fields[1] as MediaType,
      path: fields[2] as String,
      date: fields[3] as DateTime,
      latitude: fields[4] as double?,
      longitude: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, MediaModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.mediaType)
      ..writeByte(2)
      ..write(obj.path)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.latitude)
      ..writeByte(5)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MediaTypeAdapter extends TypeAdapter<MediaType> {
  @override
  final int typeId = 0;

  @override
  MediaType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MediaType.photo;
      case 1:
        return MediaType.video;
      case 2:
        return MediaType.audio;
      default:
        return MediaType.photo;
    }
  }

  @override
  void write(BinaryWriter writer, MediaType obj) {
    switch (obj) {
      case MediaType.photo:
        writer.writeByte(0);
        break;
      case MediaType.video:
        writer.writeByte(1);
        break;
      case MediaType.audio:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
