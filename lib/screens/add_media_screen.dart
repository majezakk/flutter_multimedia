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
  bool _isLoading = false;

  Future<void> _addMedia(Function() pickMethod, MediaType mediaType, String successMessage) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      dynamic result = await pickMethod();
      if (result != null) {
        String path = result is XFile ? result.path : result;
        LocationData? locationData = await LocationService.getLocation();
        MediaModel media = MediaModel(
          id: const Uuid().v4(),
          mediaType: mediaType,
          path: path,
          date: DateTime.now(),
          latitude: locationData?.latitude,
          longitude: locationData?.longitude,
        );
        await DatabaseService.addMedia(media);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addAudioUrl() async {
    if (_audioUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, введите URL аудио'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Аудио успешно загружено!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки аудио: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
        centerTitle: true,
        elevation: 2,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.background,
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Выберите тип контента',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildMediaOption(
                      icon: Icons.image,
                      title: 'Фотография',
                      subtitle: 'Добавить изображение из галереи',
                      onTap: () => _addMedia(
                          MediaService.pickImage,
                          MediaType.photo,
                          'Фото успешно загружено!'
                      ),
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _buildMediaOption(
                      icon: Icons.videocam,
                      title: 'Видео',
                      subtitle: 'Добавить видео из галереи',
                      onTap: () => _addMedia(
                          MediaService.pickVideo,
                          MediaType.video,
                          'Видео успешно загружено!'
                      ),
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    _buildMediaOption(
                      icon: Icons.folder_open,
                      title: 'Локальное аудио',
                      subtitle: 'Выбрать аудиофайл с устройства',
                      onTap: () => _addMedia(
                          MediaService.pickAudio,
                          MediaType.audio,
                          'Локальное аудио успешно загружено!'
                      ),
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 24),
                    const Text(
                      'Или добавьте аудио по URL',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _audioUrlController,
                      decoration: InputDecoration(
                        labelText: 'URL аудио',
                        hintText: 'https://example.com/audio.mp3',
                        prefixIcon: const Icon(Icons.link),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.audiotrack),
                        label: const Text('Добавить аудио по URL'),
                        onPressed: _isLoading ? null : _addAudioUrl,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Function() onTap,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}