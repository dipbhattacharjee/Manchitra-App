import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:manchitra/core/config/secrets.dart';
import 'package:manchitra/core/providers/pandal_provider.dart';
import 'package:manchitra/core/providers/navigation_controller.dart';
import 'package:manchitra/features/map/map_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: AppSecrets.supabaseUrl,
      publishableKey: AppSecrets.supabaseAnonKey,
    );
  });

  testWidgets('MapScreen widget smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PandalProvider()),
          ChangeNotifierProvider(create: (_) => NavigationController()),
        ],
        child: const MaterialApp(
          home: MapScreen(),
        ),
      ),
    );

    expect(find.byType(MapScreen), findsOneWidget);
  });
}
