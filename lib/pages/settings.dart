import 'package:flutter/material.dart';
import 'package:green_pill/pages/verificationdialog.dart';
import 'package:green_pill/service/matrix_service.dart';
import 'package:matrix/encryption/utils/key_verification.dart';
import 'package:provider/provider.dart';
import 'package:green_pill/models/settings_model.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();

    bool _isLoading = false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Darstellung',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          SwitchListTile(
            title: Text(
              'Dark Mode',
              style: TextStyle(
                color: Theme.of(context).textTheme.labelSmall?.color,
              ),
            ),
            subtitle: Text(
              'Bevorzugte Darstellung',
              style: TextStyle(
                color: Theme.of(context).textTheme.labelSmall?.color,
              ),
            ),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (value) {
              settings.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          ListTile(
            title: Text(
              'Aktuelle Primärfarbe',
              style: TextStyle(
                color: Theme.of(context).textTheme.labelSmall?.color,
              ),
            ),
            subtitle: Text(
              'Farbe der App-Elemente',
              style: TextStyle(
                color: Theme.of(context).textTheme.labelSmall?.color,
              ),
            ),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: settings.seedColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black26),
              ),
            ),
            onTap: () async {
              Color? pickedColor = await showDialog<Color>(
                context: context,
                builder: (BuildContext context) {
                  Color currentColor =
                      settings.seedColor; // Aktuelle Farbe als Startwert
                  return AlertDialog(
                    title: const Text('Farbe wählen'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: currentColor,
                        onColorChanged: (color) {
                          currentColor = color;
                        },
                        pickerAreaHeightPercent: 0.8,
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Abbrechen'),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pop(); // Dialog schließen ohne Änderung
                        },
                      ),
                      TextButton(
                        child: const Text('Auswählen'),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pop(currentColor); // Farbe zurückgeben
                        },
                      ),
                    ],
                  );
                },
              );
              if (pickedColor != null) {
                settings.setSeedColor(pickedColor); // Neue Farbe setzen
              }
            },
          ),
          ListTile(
            //TODO: Verifizierungsprozess implementieren
            title: Text(
              'Verifizierung',
              style: TextStyle(
                color: Theme.of(context).textTheme.labelSmall?.color,
              ),
            ),
            subtitle: Text(
              'Verifizieren Sie Ihre Identität',
              style: TextStyle(
                color: Theme.of(context).textTheme.labelSmall?.color,
              ),
            ),
            trailing: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: () async {
              setState(() => _isLoading = true);
              try {

                print("Start self verification");
                var request = await context.read<MatrixService>().startSelfVerification();
                
                print("Start self verification: ${request?.state}");

                if(request == null && mounted) {
                  AlertDialog(
                    title: const Text('Fehler'),
                    content: const Text('Verifizierung konnte nicht gestartet werden.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  );

                  return;
                }
                
                print("Start Dialog: ${request?.state}");

                await showDialog(
                  context: context,
                  builder: (context) => VerificationDialog(request: request!),
                );
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
          ),
        ]
      ),
    );
  }
}