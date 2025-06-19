import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class TTSScreen extends StatefulWidget {
  const TTSScreen({super.key});

  @override
  State<TTSScreen> createState() => _TTSScreenState();
}

class _TTSScreenState extends State<TTSScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _controller = TextEditingController();

  List<Map<String, String>> _voices = [];
  String? _selectedVoice;
  bool _isSpeaking = false;
  bool _loadingVoices = true;

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    try {
      final voices = await _flutterTts.getVoices as List<dynamic>;

      final filtered = voices.where((v) {
        final locale = (v['locale'] ?? '').toString().toLowerCase();
        return locale.startsWith('fr') || locale.startsWith('en');
      }).take(6).map<Map<String, String>>((v) {
        return {
          'name': v['name'] ?? 'Unknown',
          'locale': v['locale'] ?? 'Unknown',
        };
      }).toList();

      setState(() {
        _voices = filtered;
        _selectedVoice = _voices.isNotEmpty ? _voices.first['name'] : null;
        _loadingVoices = false;
      });

      _flutterTts.setCompletionHandler(() {
        setState(() => _isSpeaking = false);
      });
    } catch (e) {
      setState(() => _loadingVoices = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement voix : $e')),
      );
    }
  }

  Future<void> _speak() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un texte')),
      );
      return;
    }

    final voice = _voices.firstWhere(
      (v) => v['name'] == _selectedVoice,
      orElse: () => {},
    );

    if (voice.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voix sélectionnée invalide')),
      );
      return;
    }

    await _flutterTts.setVoice(voice);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(_controller.text);

    await _saveTextToFile(_controller.text);

    setState(() => _isSpeaking = true);
  }

  Future<void> _saveTextToFile(String text) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${dir.path}/tts_$timestamp.txt');
    await file.writeAsString(text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Texte sauvegardé : ${file.path}')),
    );
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    setState(() => _isSpeaking = false);
  }

  void _shareText() {
    if (_controller.text.trim().isNotEmpty) {
      Share.share(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Texte vers Audio')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
              ),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.mic),
              title: const Text('Audio vers Texte'),
              onTap: () => Navigator.pushNamed(context, '/stt'),
            ),
            ListTile(
              leading: const Icon(Icons.volume_up),
              title: const Text('Texte vers Audio'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Fichiers'),
              onTap: () => Navigator.pushNamed(context, '/files'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Saisissez votre texte...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            _loadingVoices
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<String>(
                    value: _selectedVoice,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Choisir une voix'),
                    items: _voices.map((v) {
                      return DropdownMenuItem(
                        value: v['name'],
                        child: Text('${v['name']} (${v['locale']})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedVoice = val);
                    },
                  ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSpeaking ? _stop : _speak,
                    icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
                    label: Text(_isSpeaking ? 'Arrêter' : 'Parler'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSpeaking ? Colors.red : Colors.green,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _controller.text.trim().isNotEmpty ? _shareText : null,
                    icon: const Icon(Icons.share),
                    label: const Text('Partager'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
