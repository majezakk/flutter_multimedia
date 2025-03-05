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
        mediaWidget = SizedBox(
          height: 300,
          child: PhotoView(
            imageProvider: FileImage(File(media.path)),
          ),
        );
        break;
      case MediaType.video:
        mediaWidget = VideoPlayerWidget(videoPath: media.path);
        break;
      case MediaType.audio:
        mediaWidget = AudioPlayerWidget(audioUrl: media.path);
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали медиа'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteMedia(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            mediaWidget,
            const SizedBox(height: 16),
            Text('Дата: ${media.date.toLocal()}'),
            const SizedBox(height: 8),
            if (media.latitude != null && media.longitude != null)
              Text(
                'Местоположение: ${media.latitude}, ${media.longitude}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
