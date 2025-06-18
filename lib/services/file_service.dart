import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class FileService {
  static Future<void> saveTextFile(String text, BuildContext context) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/transcription_${DateTime.now().millisecondsSinceEpoch}.txt');
    await file.writeAsString(text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fichier sauvegardé : ${file.path}')),
    );
  }

  static Future<List<FileSystemEntity>> listFiles() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.listSync();
  }

  static Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
