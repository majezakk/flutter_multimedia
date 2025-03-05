import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/media_model.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../services/media_service.dart';
import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';

class AddMediaScreen extends StatefulWidget {
  const AddMediaScreen({Key? key}) : super(key: key);

  @override
  _AddMediaScreenState createState() => _AddMediaScreenState();
}

class _AddMediaScreenState extends State<AddMediaScreen> {
  final TextEditingController _audioUrlController = TextEditingController();

  Future<void> _addImage() async {
    final XFile? file = await MediaService.pickImage();
    if (file != null) {
      LocationData? locationData = await LocationService.getLocation();
      MediaModel media = MediaModel(
        id: const Uuid().v4(),
        mediaType: MediaType.photo,
        path: file.path,
        date: DateTime.now(),
        latitude: locationData?.latitude,
        longitude: locationData?.longitude,
      );
      await DatabaseService.addMedia(media);
      Navigator.pop(context);
    }
  }

  Future<void> _addVideo() async {
    final XFile? file = await MediaService.pickVideo();
    if (file != null) {
      LocationData? locationData = await LocationService.getLocation();
      MediaModel media = MediaModel(
        id: const Uuid().v4(),
        mediaType: MediaType.video,
        path: file.path,
        date: DateTime.now(),
        latitude: locationData?.latitude,
        longitude: locationData?.longitude,
      );
      await DatabaseService.addMedia(media);
      Navigator.pop(context);
    }
  }

  Future<void> _addAudioUrl() async {
    if (_audioUrlController.text.isNotEmpty) {
      LocationData? locationData = await LocationService.getLocation();
      MediaModel media = MediaModel(
        id: const Uuid().v4(),
        mediaType: MediaType.audio,
        path: _audioUrlController.text.trim(),
        date: DateTime.now(),
        latitude: locationData?.latitude,
        longitude: locationData?.longitude,
      );
      await DatabaseService.addMedia(media);
      Navigator.pop(context);
    }
  }

  Future<void> _addLocalAudio() async {
    final String? audioPath = await MediaService.pickAudio();
    if (audioPath != null) {
      // Получаем текущее местоположение устройства
      LocationData? locationData = await LocationService.getLocation();
      MediaModel media = MediaModel(
        id: const Uuid().v4(),
        mediaType: MediaType.audio,
        path: audioPath,
        date: DateTime.now(),
        latitude: locationData?.latitude,
        longitude: locationData?.longitude,
      );
      await DatabaseService.addMedia(media);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _audioUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить контент'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Добавить фото'),
              onPressed: _addImage,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.videocam),
              label: const Text('Добавить видео'),
              onPressed: _addVideo,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _audioUrlController,
              decoration: const InputDecoration(
                labelText: 'URL аудио',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.audiotrack),
              label: const Text('Добавить аудио по URL'),
              onPressed: _addAudioUrl,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.folder_open),
              label: const Text('Добавить аудио с устройства'),
              onPressed: _addLocalAudio,
            ),
          ],
        ),
      ),
    );
  }
}
