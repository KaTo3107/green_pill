import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_pill/main.dart';
import 'package:green_pill/models/auth_model.dart';
import 'package:green_pill/models/settings_model.dart';
import 'package:green_pill/pages/AuthWrapper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App starts and loads AuthWrapper with Providers', (WidgetTester tester) async {
    // 1. SharedPreferences Mocken (Wichtig, da SettingsModel.load() dies wahrscheinlich nutzt)
    // Damit verhindern wir Fehler, wenn kein echtes Gerät vorhanden ist.
    SharedPreferences.setMockInitialValues({});

    // 2. Widget aufbauen
    // Da MyApp Provider benötigt, müssen wir diese hier exakt wie in der main() nachbauen.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsModel>(create: (_) {
            final model = SettingsModel();
            // Wir rufen hier evtl. model.load() auf oder lassen es, 
            // je nachdem ob wir echte Daten simulieren wollen.
            return model;
          }),
          ChangeNotifierProvider<AuthModel>(create: (_) => AuthModel()),
        ],
        child: const MyApp(), // Hier laden wir deine eigentliche App
      ),
    );

    // 3. Warten bis alles gerendert ist
    await tester.pumpAndSettle();

    // 4. Überprüfungen (Assertions)

    // Test: Wurde der AuthWrapper geladen? 
    // (Das bestätigt, dass MyApp erfolgreich gestartet ist und Routing funktioniert)
    expect(find.byType(AuthWrapper), findsOneWidget);

    // Optional: Testen ob MaterialApp existiert
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
