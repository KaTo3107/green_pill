import 'package:flutter/material.dart';
import 'package:green_pill/models/settings_model.dart';
import 'package:green_pill/pages/AuthWrapper.dart';
import 'package:flutter_vodozemac/flutter_vodozemac.dart' as vod;
import 'package:green_pill/service/matrix_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  vod.init();

  final matrix = MatrixService();
  await matrix.initialize();

  runApp(
    MultiProvider(providers: [
      //AuthModel Provider
      ChangeNotifierProvider<MatrixService>.value(value: matrix),
      //SetiingsModel Notifyier 
      ChangeNotifierProvider<SettingsModel>(create: (_) {
        final model = SettingsModel();
        model.load();
        return model;
      }),
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
