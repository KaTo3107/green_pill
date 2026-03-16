import 'package:flutter/material.dart';
import 'package:green_pill/models/settings_model.dart';
import 'package:green_pill/pages/chatlist.dart';
import 'package:green_pill/pages/settings.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
//Ein “besserer” (etwas saubererer) Ansatz
//main() lädt Settings vor
//runApp() bekommt bereits initialen State
//MyApp (MaterialApp) bleibt stabil; Theme-Wechsel passiert ohne komplette Neuziehung der App
    return ChangeNotifierProvider(
      create: (context) {
        final model = SettingsModel();
        model.load();
        return model;
      },
      child: Consumer<SettingsModel>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: settings.themeData,
            darkTheme: ThemeData.dark(useMaterial3: true)
                .copyWith(colorScheme: settings.themeData.colorScheme),
            themeMode: settings.themeMode,
            home: const MyHomePage(title: 'Green Pill Demo'),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _currentPageIndex = 0; // For bottom navigation at the Moment unused

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: <Widget>[
        const ChatListPage(),
      ][_currentPageIndex],
      /*bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) => {
          setState(() {
            _currentPageIndex = value;
          })
        },
        selectedIndex: _currentPageIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.messenger_sharp),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: const Icon(Icons.sensor_door),
            label: 'Settings',
          ),
        ],
      ),*/
    );
  }
}