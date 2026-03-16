import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:green_pill/models/settings_model.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Darstellung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: const Text('Bevorzugte Darstellung'),
          value: settings.themeMode == ThemeMode.dark,
          onChanged: (value) {
            settings.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
          },
        ),

        const SizedBox(height: 20),
        const Text('Primärfarbe wählen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ColorChoice(
              color: Colors.blue,
              selected: settings.seedColor == Colors.blue,
              onTap: () => settings.setSeedColor(Colors.blue),
            ),
            _ColorChoice(
              color: Colors.green,
              selected: settings.seedColor == Colors.green,
              onTap: () => settings.setSeedColor(Colors.green),
            ),
            _ColorChoice(
              color: Colors.pink,
              selected: settings.seedColor == Colors.pink,
              onTap: () => settings.setSeedColor(Colors.pink),
            ),
            _ColorChoice(
              color: Colors.deepOrange,
              selected: settings.seedColor == Colors.deepOrange,
              onTap: () => settings.setSeedColor(Colors.deepOrange),
            ),
          ],
        ),
      ],
    );
  }
}

class _ColorChoice extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorChoice({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: color,
        radius: selected ? 26 : 22,
        child: selected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}