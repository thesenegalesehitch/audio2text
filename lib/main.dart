import 'package:flutter/material.dart';
import 'screens/stt_screen.dart';
import 'screens/tts_screen.dart';
import 'screens/files_screen.dart';

void main() {
  runApp(const AudioTextConverterApp());
}

class AudioTextConverterApp extends StatelessWidget {
  const AudioTextConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AudioText Converter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const STTScreen(),
        '/tts': (_) => const TTSScreen(),
        '/files': (_) => const FilesScreen(),
      },
    );
  }
}
