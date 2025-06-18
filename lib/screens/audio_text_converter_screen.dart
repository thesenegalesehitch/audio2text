import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:share_plus/share_plus.dart';

class AudioTextConverterScreen extends StatefulWidget {
  const AudioTextConverterScreen({super.key});

  @override
  State<AudioTextConverterScreen> createState() => _AudioTextConverterScreenState();
}

class _AudioTextConverterScreenState extends State<AudioTextConverterScreen> {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  final TextEditingController _transcribedController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();

  String _selectedLang = 'en-US';

  final List<Map<String, String>> _languages = [
    {'name': 'English (US)', 'code': 'en-US'},
    {'name': 'Français (France)', 'code': 'fr-FR'},
    {'name': 'Español (España)', 'code': 'es-ES'},
    {'name': 'Deutsch', 'code': 'de-DE'},
    {'name': '中文', 'code': 'zh-CN'},
    {'name': 'العربية', 'code': 'ar-SA'},
    {'name': 'हिन्दी', 'code': 'hi-IN'},
    // Ajoutez d'autres langues au besoin
  ];

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      await _speech.listen(
        localeId: _selectedLang,
        onResult: (result) {
          _transcribedController.text = result.recognizedWords;
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Speech-to-text non disponible")),
      );
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
  }

  Future<void> _speakText() async {
    await _flutterTts.setLanguage(_selectedLang);
    await _flutterTts.speak(_inputController.text);
  }

  Future<void> _saveTextFile() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      final file = File('$path/transcription_${DateTime.now().millisecondsSinceEpoch}.txt');
      await file.writeAsString(_transcribedController.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Texte sauvegardé")));
    }
  }

  Future<void> _loadTextFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['txt']);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      _inputController.text = content;
    }
  }

  Future<void> _shareText() async {
    if (_transcribedController.text.isNotEmpty) {
      await Share.share(_transcribedController.text, subject: 'Ma transcription');
    }
  }

  @override
  void dispose() {
    _transcribedController.dispose();
    _inputController.dispose();
    super.dispose();
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
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: _startListening,
                  icon: const Icon(Icons.mic),
                  label: const Text("Démarrer"),
                ),
                ElevatedButton.icon(
                  onPressed: _stopListening,
                  icon: const Icon(Icons.stop),
                  label: const Text("Arrêter"),
                ),
                ElevatedButton.icon(
                  onPressed: _saveTextFile,
                  icon: const Icon(Icons.save),
                  label: const Text("Sauvegarder"),
                ),
                ElevatedButton.icon(
                  onPressed: _shareText,
                  icon: const Icon(Icons.share),
                  label: const Text("Partager"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _transcribedController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Texte transcrit",
              ),
              readOnly: true,
            ),
            const Divider(height: 40),
            TextField(
              controller: _inputController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Texte à lire",
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: _speakText,
                  icon: const Icon(Icons.volume_up),
                  label: const Text("Lire"),
                ),
                ElevatedButton.icon(
                  onPressed: _loadTextFile,
                  icon: const Icon(Icons.folder_open),
                  label: const Text("Charger fichier"),
                ),
              ],
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
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
            ),
            child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.mic),
            title: const Text("Transcription"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.volume_up),
            title: const Text("Synthèse vocale"),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
