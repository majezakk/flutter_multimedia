import 'package:hive/hive.dart';
part 'media_model.g.dart';

@HiveType(typeId: 0)
enum MediaType {
  @HiveField(0)
  photo,
  @HiveField(1)
  video,
  @HiveField(2)
  audio,
}

@HiveType(typeId: 1)
class MediaModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  MediaType mediaType;
  @HiveField(2)
  String path; // Путь к файлу или URL
  @HiveField(3)
  DateTime date;
  @HiveField(4)
  double? latitude;
  @HiveField(5)
  double? longitude;

  MediaModel({
    required this.id,
    required this.mediaType,
    required this.path,
    required this.date,
    this.latitude,
    this.longitude,
  });
}
