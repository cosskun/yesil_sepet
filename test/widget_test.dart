import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:yesil_sepet/controllers/controllers.dart';
import 'package:yesil_sepet/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthController()),
          ChangeNotifierProvider(create: (_) => ShoppingController()),
        ],
        child: const MyApp(),
      ),
    );

    // Pump to allow splash animation and navigation timer to settle
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.byType(MyApp), findsOneWidget);
  });
}
