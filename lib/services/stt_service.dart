import 'package:speech_to_text/speech_to_text.dart' as stt;

class STTService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  Future<String> listen(String locale) async {
    String resultText = '';
    bool available = await _speech.initialize();
    if (available) {
      await _speech.listen(
        onResult: (result) {
          resultText = result.recognizedWords;
        },
        localeId: locale,
      );
      await Future.delayed(const Duration(seconds: 5));
      await _speech.stop();
    }
    return resultText;
  }

  Future<void> stop() async {
    await _speech.stop();
  }

  Future<List<stt.LocaleName>> getLocales() async {
    await _speech.initialize();
    return _speech.locales();
  }
}
