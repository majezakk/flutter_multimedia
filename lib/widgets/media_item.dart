import 'dart:io';
import 'package:flutter/material.dart';
import '../models/media_model.dart';
import '../screens/media_detail_screen.dart';

class MediaItem extends StatelessWidget {
  final MediaModel media;
  const MediaItem({Key? key, required this.media}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget thumbnail;
    switch (media.mediaType) {
      case MediaType.photo:
        thumbnail = Image.file(
          File(media.path),
          fit: BoxFit.cover,
          height: 200,
          width: double.infinity,
        );
        break;
      case MediaType.video:
        thumbnail = Stack(
          children: [
            Container(
              height: 200,
              color: Colors.black12,
              width: double.infinity,
              child: const Center(child: Icon(Icons.videocam, size: 50)),
            ),
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(Icons.play_circle_fill,
                  color: Colors.white, size: 30),
            )
          ],
        );
        break;
      case MediaType.audio:
        thumbnail = Container(
          height: 100,
          color: Colors.blueAccent,
          width: double.infinity,
          child: const Center(
              child:
              Icon(Icons.audiotrack, size: 50, color: Colors.white)),
        );
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MediaDetailScreen(media: media)));
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            thumbnail,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Дата: ${media.date.toLocal()}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }
}
