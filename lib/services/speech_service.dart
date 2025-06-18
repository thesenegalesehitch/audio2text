import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();

  Future<String> listen() async {
    await _speech.initialize();
    String result = '';
    await _speech.listen(
      onResult: (val) => result = val.recognizedWords,
      localeId: 'fr-FR', // Change dynamique possible
    );
    await Future.delayed(const Duration(seconds: 5)); // Ex pour test
    await _speech.stop();
    return result;
  }

  Future<void> stop() async {
    await _speech.stop();
  }
}
