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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Мультимедиа Лента',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Сохраняем текущий функционал (ничего не делаем)
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ValueListenableBuilder(
          valueListenable: mediaBox.listenable(),
          builder: (context, Box<MediaModel> box, _) {
            final mediaList = box.values.toList();

            if (mediaList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 64,
                      color: theme.colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Нет контента',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Нажмите кнопку "+" чтобы добавить медиа',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                // Просто заглушка для функции обновления
                await Future.delayed(const Duration(milliseconds: 800));
                return;
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: mediaList.length,
                  itemBuilder: (context, index) {
                    final media = mediaList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Card(
                        elevation: 2,
                        shadowColor: theme.shadowColor.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: MediaItem(media: media),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Добавить'),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMediaScreen()));
        },
      ),
    );
  }
}