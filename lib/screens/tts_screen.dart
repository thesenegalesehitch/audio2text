import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSScreen extends StatefulWidget {
  const TTSScreen({super.key});

  @override
  State<TTSScreen> createState() => _TTSScreenState();
}

class _TTSScreenState extends State<TTSScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  String _textToSpeak = '';
  bool _isSpeaking = false;
  List<dynamic> _voices = [];
  String? _selectedVoice;

  @override
  void initState() {
    super.initState();
    _initTTS();
  }

  Future<void> _initTTS() async {
    _voices = await _flutterTts.getVoices;
    setState(() {});
  }

  Future<void> _speak() async {
    if (_textToSpeak.isNotEmpty) {
      await _flutterTts.setVoice(_voices.firstWhere(
        (voice) => voice['name'] == _selectedVoice,
        orElse: () => _voices.first,
      ));
      await _flutterTts.speak(_textToSpeak);
      setState(() {
        _isSpeaking = true;
      });
      _flutterTts.setCompletionHandler(() {
        setState(() {
          _isSpeaking = false;
        });
      });
    }
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    setState(() {
      _isSpeaking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Texte vers audio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Entrez du texte...',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  _textToSpeak = val;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedVoice,
              hint: const Text('Choisir une voix'),
              items: _voices.map<DropdownMenuItem<String>>((voice) {
                return DropdownMenuItem<String>(
                  value: voice['name'] as String,
                  child: Text('${voice['name']} (${voice['locale']})'),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedVoice = val;
                });
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
                  label: Text(_isSpeaking ? 'Arrêter' : 'Parler'),
                  onPressed: _isSpeaking ? _stop : _speak,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
