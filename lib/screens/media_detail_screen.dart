import 'dart:io';
import 'package:flutter/material.dart';
import '../models/media_model.dart';
import 'package:photo_view/photo_view.dart';
import '../widgets/video_player.dart';
import '../widgets/audio_player.dart';

class MediaDetailScreen extends StatelessWidget {
  final MediaModel media;
  const MediaDetailScreen({Key? key, required this.media}) : super(key: key);

  Future<void> _deleteMedia(BuildContext context) async {
    await media.delete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Widget mediaWidget;
    switch (media.mediaType) {
      case MediaType.photo:
        mediaWidget = Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: PhotoView(
            imageProvider: FileImage(File(media.path)),
            backgroundDecoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          ),
        );
        break;
      case MediaType.video:
        mediaWidget = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: VideoPlayerWidget(videoPath: media.path),
        );
        break;
      case MediaType.audio:
        mediaWidget = Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AudioPlayerWidget(audioUrl: media.path),
          ),
        );
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали медиа'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteMedia(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Медиа контент
              mediaWidget,

              const SizedBox(height: 24),

              // Информация о медиа
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        context,
                        Icons.calendar_today,
                        'Дата:',
                        media.date.toLocal().toString().split('.')[0],
                      ),

                      if (media.latitude != null && media.longitude != null)
                        _buildInfoRow(
                          context,
                          Icons.location_on,
                          'Местоположение:',
                          '${media.latitude!.toStringAsFixed(6)}, ${media.longitude!.toStringAsFixed(6)}',
                        ),

                      _buildInfoRow(
                        context,
                        _getMediaTypeIcon(),
                        'Тип:',
                        _getMediaTypeText(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMediaTypeIcon() {
    switch (media.mediaType) {
      case MediaType.photo:
        return Icons.image;
      case MediaType.video:
        return Icons.movie;
      case MediaType.audio:
        return Icons.audiotrack;
    }
  }

  String _getMediaTypeText() {
    switch (media.mediaType) {
      case MediaType.photo:
        return 'Фотография';
      case MediaType.video:
        return 'Видео';
      case MediaType.audio:
        return 'Аудио';
    }
  }
}