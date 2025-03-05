import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class MediaService {
  static final ImagePicker _picker = ImagePicker();

  // Выбор изображения из галереи
  static Future<XFile?> pickImage() async {
    return await _picker.pickImage(source: ImageSource.gallery);
  }

  // Выбор видео из галереи
  static Future<XFile?> pickVideo() async {
    return await _picker.pickVideo(source: ImageSource.gallery);
  }

  // Выбор аудио из устройства
  static Future<String?> pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'aac', 'wav'],
    );
    if (result != null && result.files.isNotEmpty) {
      return result.files.single.path;
    }
    return null;
  }
}
