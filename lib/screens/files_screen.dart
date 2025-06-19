import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/custom_drawer.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  List<File> _files = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFiles();  // Recharge les fichiers au retour sur cet écran
  }

  Future<void> _loadFiles() async {
    try {
      setState(() => _loading = true);

      final dir = await getApplicationDocumentsDirectory();
      final allFiles = await dir.list().toList();
      final txtFiles = allFiles
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.txt'))
          .toList()
        ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      setState(() {
        _files = txtFiles;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement fichiers : $e')),
      );
    }
  }

  Future<void> _deleteFile(File file) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le fichier ?'),
        content: Text('Voulez-vous supprimer "${file.uri.pathSegments.last}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await file.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${file.uri.pathSegments.last} supprimé')),
        );
        await _loadFiles();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur suppression : $e')),
        );
      }
    }
  }

  Future<void> _openFile(File file) async {
    try {
      final content = await file.readAsString();
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(file.uri.pathSegments.last),
          content: SingleChildScrollView(child: Text(content)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur ouverture : $e')),
      );
    }
  }

  Future<void> _shareFile(File file) async {
    try {
      await Share.shareFiles([file.path], text: 'Voici un fichier de transcription');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur partage : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fichiers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFiles,
            tooltip: 'Rafraîchir',
          )
        ],
      ),
      drawer: const CustomDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
              ? const Center(child: Text('Aucun fichier trouvé'))
              : ListView.builder(
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final file = _files[index];
                    final name = file.uri.pathSegments.last;
                    final modified = file.lastModifiedSync().toLocal();

                    return ListTile(
                      leading: const Icon(Icons.description),
                      title: Text(name),
                      subtitle: Text('Modifié : ${modified.toString().split('.').first}'),
                      onTap: () => _openFile(file),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.blue),
                            onPressed: () => _shareFile(file),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteFile(file),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
