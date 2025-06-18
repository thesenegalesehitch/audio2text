import 'package:flutter/material.dart';
import 'package:audio_text_converter/screens/stt_screen.dart';
import 'package:audio_text_converter/screens/tts_screen.dart';
import 'package:audio_text_converter/screens/files_screen.dart';
import 'package:audio_text_converter/widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    STTScreen(),
    TTSScreen(),
    FilesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Transcrire'),
          BottomNavigationBarItem(icon: Icon(Icons.volume_up), label: 'Parler'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Fichiers'),
        ],
      ),
    );
  }
}
