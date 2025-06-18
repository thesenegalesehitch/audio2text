// lib/screens/audio_text_converter_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AudioTextConverterScreen extends StatefulWidget {
  const AudioTextConverterScreen({super.key});
  @override
  State<AudioTextConverterScreen> createState() => _AudioTextConverterScreenState();
}

class _AudioTextConverterScreenState extends State<AudioTextConverterScreen> {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  String _transcribedText = '';
  String _inputText = '';
  String _selectedLang = 'en-US';

  final List<Map<String, String>> _languages = [
    {'name': 'English (US)', 'code': 'en-US'},
    {'name': 'Français (France)', 'code': 'fr-FR'},
    {'name': 'Español (España)', 'code': 'es-ES'},
    {'name': 'Deutsch', 'code': 'de-DE'},
    {'name': '中文', 'code': 'zh-CN'},
    {'name': 'العربية', 'code': 'ar-SA'},
    {'name': 'हिन्दी', 'code': 'hi-IN'},
    // Ajoute plus de langues si tu veux
  ];

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      await _speech.listen(
        localeId: _selectedLang,
        onResult: (result) {
          setState(() {
            _transcribedText = result.recognizedWords;
          });
        },
      );
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
  }

  Future<void> _speakText() async {
    await _flutterTts.setLanguage(_selectedLang);
    await _flutterTts.speak(_inputText);
  }

  Future<void> _saveTextFile() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      final file = File('$path/transcription_${DateTime.now().millisecondsSinceEpoch}.txt');
      await file.writeAsString(_transcribedText);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Texte sauvegardé")));
    }
  }

  Future<void> _loadTextFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['txt']);
    if (result != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      setState(() {
        _inputText = content;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(title: const Text("AudioText Converter")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedLang,
              decoration: const InputDecoration(labelText: 'Langue'),
              items: _languages.map((lang) {
                return DropdownMenuItem(value: lang['code'], child: Text(lang['name']!));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLang = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _startListening,
              icon: const Icon(Icons.mic),
              label: const Text("Démarrer la transcription"),
            ),
            ElevatedButton.icon(
              onPressed: _stopListening,
              icon: const Icon(Icons.stop),
              label: const Text("Arrêter"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: TextEditingController(text: _transcribedText),
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Texte transcrit",
              ),
              readOnly: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveTextFile,
              icon: const Icon(Icons.save),
              label: const Text("Sauvegarder le texte"),
            ),
            const Divider(),
            TextField(
              onChanged: (value) {
                _inputText = value;
              },
              controller: TextEditingController(text: _inputText),
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Texte à convertir en audio",
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _speakText,
              icon: const Icon(Icons.volume_up),
              label: const Text("Lire le texte"),
            ),
            ElevatedButton.icon(
              onPressed: _loadTextFile,
              icon: const Icon(Icons.folder_open),
              label: const Text("Charger un fichier texte"),
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple])),
            child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.mic),
            title: const Text("Transcription audio"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.volume_up),
            title: const Text("Synthèse vocale"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
