import 'package:speech_to_text/speech_to_text.dart';

class STTService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  /// Initialise le STT si pas déjà fait
  Future<bool> initialize({
    void Function(String status)? onStatus,
    void Function(String error)? onError,
  }) async {
    if (_initialized) return true;

    final available = await _speech.initialize(
      onStatus: onStatus,
      onError: (error) {
        // Le paramètre error.errorMsg existe
        onError?.call(error.errorMsg);
      },
    );

    _initialized = available;
    return available;
  }

  /// Récupère la liste des langues supportées
  Future<List<LocaleName>> getLocales() async {
    if (!_initialized) {
      await initialize();
    }
    return await _speech.locales();
  }

  /// Lance l'écoute
  Future<void> listen({
    required Function(String recognizedText) onResult,
    String? localeId,
  }) async {
    if (!_initialized) {
      final success = await initialize();
      if (!success) {
        throw Exception("STT non disponible");
      }
    }

    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      localeId: localeId,
      listenMode: ListenMode.dictation,
    );
  }

  /// Arrête l'écoute
  Future<void> stop() async {
    if (_initialized && _speech.isListening) {
      await _speech.stop();
    }
  }

  /// Vérifie si l'écoute est active
  bool get isListening => _speech.isListening;
}
