import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/media_model.dart';

class DatabaseService {
  static const String mediaBoxName = 'mediaBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MediaTypeAdapter());
    Hive.registerAdapter(MediaModelAdapter());
    await Hive.openBox<MediaModel>(mediaBoxName);
  }

  static Box<MediaModel> getMediaBox() {
    return Hive.box<MediaModel>(mediaBoxName);
  }

  static Future<void> addMedia(MediaModel media) async {
    final box = getMediaBox();
    await box.put(media.id, media);
  }

  static List<MediaModel> getAllMedia() {
    final box = getMediaBox();
    return box.values.toList();
  }
}
