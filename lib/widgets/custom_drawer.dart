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
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.mic),
            title: const Text('Audio vers texte'),
            onTap: () {
              Navigator.pushNamed(context, '/stt');
            },
          ),
          ListTile(
            leading: const Icon(Icons.volume_up),
            title: const Text('Texte vers audio'),
            onTap: () {
              Navigator.pushNamed(context, '/tts');
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Fichiers'),
            onTap: () {
              Navigator.pushNamed(context, '/files');
            },
          ),
        ],
      ),
    );
  }
}
