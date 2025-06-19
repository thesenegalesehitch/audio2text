import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();

  /// Récupère la liste des voix disponibles
  Future<List<dynamic>> getVoices() async {
    return await _flutterTts.getVoices;
  }

  /// Configure la voix à utiliser pour la lecture
  Future<void> setVoice(Map<String, dynamic> voice) async {
    // Conversion en Map<String, String> pour correspondre au type attendu
    final Map<String, String> stringVoice = voice.map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
    await _flutterTts.setVoice(stringVoice);
  }

  /// Lance la lecture du texte
  Future<void> speak(String text) async {
    if (text.trim().isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  /// Arrête la lecture en cours
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// Définit un gestionnaire de fin de lecture
  void setCompletionHandler(Function() onComplete) {
    _flutterTts.setCompletionHandler(onComplete);
  }
}
