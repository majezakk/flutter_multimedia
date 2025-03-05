import 'package:flutter/material.dart';
import 'services/database_service.dart';
import 'screens/gallery_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Multimedia',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GalleryScreen(),
    );
  }
}
