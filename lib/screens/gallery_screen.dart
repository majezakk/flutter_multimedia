import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/media_model.dart';
import '../services/database_service.dart';
import '../widgets/media_item.dart';
import 'add_media_screen.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaBox = DatabaseService.getMediaBox();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мультимедиа Лента'),
      ),
      body: ValueListenableBuilder(
        valueListenable: mediaBox.listenable(),
        builder: (context, Box<MediaModel> box, _) {
          final mediaList = box.values.toList();
          if (mediaList.isEmpty) {
            return const Center(child: Text('Нет контента'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: mediaList.length,
            itemBuilder: (context, index) {
              final media = mediaList[index];
              return MediaItem(media: media);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMediaScreen()));
        },
      ),
    );
  }
}
