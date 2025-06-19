import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class FileService {
  /// Sauvegarde un texte dans un fichier avec timestamp
  static Future<void> saveTextFile(String text, BuildContext context) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${dir.path}/transcription_$timestamp.txt');
      await file.writeAsString(text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fichier sauvegardé : ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur sauvegarde : $e')),
      );
    }
  }

  /// Liste les fichiers texte (.txt) dans le dossier documents
  static Future<List<FileSystemEntity>> listFiles() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = await dir.list().where((f) => f.path.endsWith('.txt')).toList();
    return files;
  }

  /// Supprime un fichier à un chemin donné
  static Future<void> deleteFile(String path, BuildContext context) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fichier supprimé : ${file.uri.pathSegments.last}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fichier non trouvé')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur suppression : $e')),
      );
    }
  }
}
