import 'package:flutter/material.dart';
import 'screens/stt_screen.dart';
import 'screens/tts_screen.dart';
import 'screens/files_screen.dart';
import 'widgets/custom_drawer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AudioText Converter',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: '/stt',
      routes: {
        '/stt': (context) => const STTScreen(),
        '/tts': (context) => const TTSScreen(),
        '/files': (context) => const FilesScreen(),
      },
    );
  }
}
