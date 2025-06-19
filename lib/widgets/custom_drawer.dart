import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
            ),
            child: Text('AudioText Converter', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.mic),
            title: const Text('Audio vers Texte'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.volume_up),
            title: const Text('Texte vers Audio'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/tts');
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Gestion Fichiers'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/files');
            },
          ),
        ],
      ),
    );
  }
}
