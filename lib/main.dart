import 'package:flutter/material.dart';
import 'package:green_pill/models/auth_model.dart';
import 'package:green_pill/models/settings_model.dart';
import 'package:green_pill/pages/AuthWrapper.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(providers: [
      //SetiingsModel Notifyier 
      ChangeNotifierProvider<SettingsModel>(create: (_) {
        final model = SettingsModel();
        model.load();
        return model;
      }),
      //AuthModel Notifyier
      ChangeNotifierProvider<AuthModel>(create: (_) => AuthModel()),
    ],
    builder: (context, child) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: context.watch<SettingsModel>().themeData,
      darkTheme: ThemeData.dark(useMaterial3: true)
          .copyWith(colorScheme: context.watch<SettingsModel>().themeData.colorScheme),
      themeMode: context.watch<SettingsModel>().themeMode,
      home: const AuthWrapper(),
    );
  }
}
