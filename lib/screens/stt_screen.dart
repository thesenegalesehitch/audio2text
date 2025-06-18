import 'dart:io';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class STTScreen extends StatefulWidget {
  const STTScreen({super.key});

  @override
  State<STTScreen> createState() => _STTScreenState();
}

class _STTScreenState extends State<STTScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';
  String? _selectedLocaleId;
  List<stt.LocaleName> _locales = [];
  String _detectedLocale = '';
  bool _autoDetect = true;
  bool _loadingLocales = true;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() {
            _isListening = false;
          });
          _saveTextToFile(auto: true);
        }
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur STT: ${error.errorMsg}')),
        );
      },
    );

    if (available) {
      try {
        final locales = await _speech.locales();
        setState(() {
          _locales = locales;
          _selectedLocaleId = _locales.isNotEmpty ? _locales.first.localeId : null;
          _loadingLocales = false;
        });
      } catch (e) {
        setState(() => _loadingLocales = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement langues : $e')),
        );
      }
    } else {
      setState(() => _loadingLocales = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Speech-to-Text non disponible ou refusé")),
      );
    }
  }

  Future<void> _startOrStopListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      await _saveTextToFile(auto: true);
    } else {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
            if (_autoDetect) {
              _speech.systemLocale().then((locale) {
                setState(() {
                  _detectedLocale = locale?.localeId ?? '';
                });
              });
            }
          });
        },
        localeId: _autoDetect ? null : _selectedLocaleId,
        listenMode: stt.ListenMode.dictation,
      );
      setState(() {
        _isListening = true;
        _detectedLocale = '';
      });
    }
  }

  Future<void> _saveTextToFile({bool auto = false}) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${dir.path}/transcription_$timestamp.txt');
    await file.writeAsString(_text);
    if (!auto) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Texte sauvegardé : ${file.path}')),
      );
    }
  }

  Future<void> _importAudioFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Importation audio détectée. STT sur fichier : backend requis.')),
      );
    }
  }

  void _shareText() {
    if (_text.isNotEmpty) {
      Share.share(_text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio vers Texte'),
      ),
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
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.volume_up),
              title: const Text('Texte vers Audio'),
              onTap: () => Navigator.pushNamed(context, '/tts'),
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
            Row(
              children: [
                Checkbox(
                  value: _autoDetect,
                  onChanged: (val) {
                    setState(() {
                      _autoDetect = val ?? true;
                    });
                  },
                ),
                const Text("Détection automatique de la langue"),
              ],
            ),
            if (!_autoDetect)
              _loadingLocales
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: _selectedLocaleId,
                      decoration: const InputDecoration(labelText: 'Choisir une langue'),
                      items: _locales.map((locale) {
                        return DropdownMenuItem(
                          value: locale.localeId,
                          child: Text(locale.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedLocaleId = val;
                        });
                      },
                    ),
            if (_detectedLocale.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Langue détectée : $_detectedLocale',
                    style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _startOrStopListening,
              icon: Icon(_isListening ? Icons.stop : Icons.mic),
              label: Text(_isListening ? 'Arrêter' : 'Démarrer'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: _isListening ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _text.isEmpty ? 'Votre transcription apparaîtra ici...' : _text,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _text.isNotEmpty ? _saveTextToFile : null,
                    icon: const Icon(Icons.save),
                    label: const Text('Sauvegarder'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _importAudioFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Importer Audio'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _text.isNotEmpty ? _shareText : null,
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
