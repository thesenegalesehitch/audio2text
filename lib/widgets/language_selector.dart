import 'package:flutter/material.dart';
import '../services/stt_service.dart';
import '../services/tts_service.dart';

class LanguageSelector extends StatefulWidget {
  final Function(String) onLanguageChanged;
  final String mode; // 'stt' ou 'tts'

  const LanguageSelector({
    super.key,
    required this.onLanguageChanged,
    required this.mode,
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  List<Map<String, String>> _locales = [];
  String? _currentLocale;

  @override
  void initState() {
    super.initState();
    _loadLocales();
  }

  Future<void> _loadLocales() async {
    if (widget.mode == 'stt') {
      final locales = await STTService().getLocales();
      setState(() {
        _locales = locales
            .map((e) => {'name': e.name, 'localeId': e.localeId})
            .toList();
        _currentLocale = _locales.first['localeId'];
        widget.onLanguageChanged(_currentLocale!);
      });
    } else {
      final tts = TTSService();
      final voices = await tts.getVoices();
      final uniqueLocales = voices
          .map((v) => v['locale'].toString())
          .toSet()
          .map((l) => {'name': l, 'localeId': l})
          .toList();
      setState(() {
        _locales = uniqueLocales;
        _currentLocale = _locales.first['localeId'];
        widget.onLanguageChanged(_currentLocale!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _currentLocale,
      items: _locales
          .map((l) => DropdownMenuItem(
                value: l['localeId'],
                child: Text(l['name'] ?? ''),
              ))
          .toList(),
      onChanged: (val) {
        if (val != null) {
          setState(() => _currentLocale = val);
          widget.onLanguageChanged(val);
        }
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Langue',
      ),
    );
  }
}
