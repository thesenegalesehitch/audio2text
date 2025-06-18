import 'package:flutter/material.dart';
import '../services/speech_service.dart';
import '../services/file_service.dart';

class TranscriptionScreen extends StatefulWidget {
  const TranscriptionScreen({super.key});

  @override
  State<TranscriptionScreen> createState() => _TranscriptionScreenState();
}

class _TranscriptionScreenState extends State<TranscriptionScreen> {
  final SpeechService _speechService = SpeechService();
  String _transcribed = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio vers Texte')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final result = await _speechService.listen();
                setState(() {
                  _transcribed = result;
                });
              },
              icon: const Icon(Icons.mic),
              label: const Text('Démarrer'),
            ),
            ElevatedButton.icon(
              onPressed: _speechService.stop,
              icon: const Icon(Icons.stop),
              label: const Text('Arrêter'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_transcribed),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _transcribed.isNotEmpty
                  ? () => FileService.saveTextFile(_transcribed, context)
                  : null,
              icon: const Icon(Icons.save),
              label: const Text('Sauvegarder'),
            ),
          ],
        ),
      ),
    );
  }
}
