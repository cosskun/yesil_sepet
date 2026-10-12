import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:yesil_sepet/controllers/controllers.dart';
import 'package:yesil_sepet/data/models/user.dart';
import 'package:yesil_sepet/data/repositories/mock/mock_auth_repository.dart';
import 'package:yesil_sepet/data/repositories/mock/mock_shopping_repository.dart';
import 'package:yesil_sepet/screens/dashboard_screen.dart';
import 'package:yesil_sepet/screens/forgot_password_screen.dart';
import 'package:yesil_sepet/screens/home_screen.dart';
import 'package:yesil_sepet/screens/join_screen.dart';
import 'package:yesil_sepet/screens/list_detail_screen.dart';
import 'package:yesil_sepet/screens/login_screen.dart';
import 'package:yesil_sepet/screens/register_screen.dart';
import 'package:yesil_sepet/screens/settings_dialog.dart';
import 'package:yesil_sepet/screens/splash_screen.dart';
import 'package:yesil_sepet/theme/theme.dart';

Widget createTestApp({
  required Widget child,
  required AuthController authController,
  required ShoppingController shoppingController,
  TargetPlatform platform = TargetPlatform.iOS,
}) {
  return MultiProvider(
    key: UniqueKey(),
    providers: [
      ChangeNotifierProvider<AuthController>.value(value: authController),
      ChangeNotifierProvider<ShoppingController>.value(value: shoppingController),
    ],
    child: MaterialApp(
      key: UniqueKey(),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme.copyWith(platform: platform),
      home: child,
    ),
  );
}

void setPhoneDimensions(WidgetTester tester, {double width = 393, double height = 852}) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository authRepo;
  late MockShoppingRepository shoppingRepo;
  late AuthController authController;
  late ShoppingController shoppingController;

  setUp(() {
    authRepo = MockAuthRepository();
    shoppingRepo = MockShoppingRepository();
    authController = AuthController(authRepository: authRepo);
    shoppingController = ShoppingController(shoppingRepository: shoppingRepo);
    shoppingController.enablePolling = false;
  });

  tearDown(() {
    shoppingController.stopPolling();
  });

  group('Comprehensive Screen & Interaction Tests (iOS & Android)', () {
    // 1. SPLASH SCREEN
    testWidgets('SplashScreen renders and animates cleanly on iOS & Android',
        (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);

      for (var platform in [TargetPlatform.iOS, TargetPlatform.android]) {
        authController.logout();
        setPhoneDimensions(tester, width: 393, height: 852);

        await tester.pumpWidget(createTestApp(
          child: const SplashScreen(),
          authController: authController,
          shoppingController: shoppingController,
          platform: platform,
        ));

        expect(find.text('Yeşil Sepet'), findsOneWidget);
        expect(find.text('Kolay ve Senkronize Alışveriş'), findsOneWidget);

        // Advance animation past the 2-second navigation delay
        await tester.pump(const Duration(milliseconds: 1200));
        await tester.pump(const Duration(milliseconds: 1000));
        await tester.pumpAndSettle();
        expect(find.text('Hoş Geldiniz'), findsOneWidget);
      }
    });

    // 2. LOGIN SCREEN
    testWidgets('LoginScreen inputs, validation, and buttons work on iOS & Android',
        (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);

      for (var platform in [TargetPlatform.iOS, TargetPlatform.android]) {
        authController.logout();
        setPhoneDimensions(tester, width: 393, height: 852);

        await tester.pumpWidget(createTestApp(
          child: const LoginScreen(),
          authController: authController,
          shoppingController: shoppingController,
          platform: platform,
        ));

        expect(find.text('Hoş Geldiniz'), findsOneWidget);
        expect(find.text('Giriş Yap'), findsOneWidget);

        // Tap Giriş Yap with empty fields -> verify error messages
        await tester.ensureVisible(find.text('Giriş Yap'));
        await tester.tap(find.text('Giriş Yap'));
        await tester.pumpAndSettle();
        expect(find.text('Lütfen e-posta adresinizi girin.'), findsOneWidget);

        // Toggle password visibility
        final visibilityBtn = find.byIcon(Icons.visibility_outlined);
        expect(visibilityBtn, findsOneWidget);
        await tester.tap(visibilityBtn);
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

        // Fill credentials
        await tester.enterText(
            find.byType(TextFormField).first, 'test@test.com');
        await tester.enterText(
            find.byType(TextFormField).last, 'password123');
        await tester.pumpAndSettle();

        // Tap submit
        await tester.ensureVisible(find.text('Giriş Yap'));
        await tester.tap(find.text('Giriş Yap'));
        await tester.pump(const Duration(milliseconds: 700));
        await tester.pumpAndSettle();

        expect(authController.currentUser, isNotNull);
      }
    });

    // 3. REGISTER SCREEN
    testWidgets('RegisterScreen form validation and submission work',
        (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      authController.logout();
      setPhoneDimensions(tester, width: 375, height: 812);

      await tester.pumpWidget(createTestApp(
        child: const RegisterScreen(),
        authController: authController,
        shoppingController: shoppingController,
      ));

      expect(find.text('Yeni Hesap Oluştur'), findsOneWidget);

      // Submit empty
      await tester.ensureVisible(find.text('Kayıt Ol'));
      await tester.tap(find.text('Kayıt Ol'));
      await tester.pumpAndSettle();
      expect(find.text('Lütfen adınızı girin.'), findsOneWidget);

      // Fill matching details
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Ali Veli');
      await tester.enterText(textFields.at(1), 'ali@veli.com');
      await tester.enterText(textFields.at(2), 'secret123');
      await tester.enterText(textFields.at(3), 'secret123');
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Kayıt Ol'));
      await tester.tap(find.text('Kayıt Ol'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Kayıt başarılı'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    // 4. FORGOT PASSWORD SCREEN
    testWidgets('ForgotPasswordScreen email reset dialog works',
        (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      setPhoneDimensions(tester, width: 393, height: 852);

      await tester.pumpWidget(createTestApp(
        child: const ForgotPasswordScreen(),
        authController: authController,
        shoppingController: shoppingController,
      ));

      expect(find.text('Şifremi Unuttum'), findsOneWidget);

      await tester.enterText(
          find.byType(TextFormField), 'test@test.com');
      await tester.ensureVisible(find.text('Şifremi Sıfırla'));
      await tester.tap(find.text('Şifremi Sıfırla'));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.text('Şifre Sıfırlandı'), findsOneWidget);
      expect(find.text('Giriş Ekranına Dön'), findsOneWidget);
    });

    // 5. HOME SCREEN
    testWidgets('HomeScreen cards, stats, and dialogs work on iOS & Android',
        (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      authController.setGuestUser(const User(id: '1', email: 'test@test.com', name: 'Ayşe'));
      shoppingController.fetchLists('1');
      await tester.pump(const Duration(milliseconds: 400));

      for (var platform in [TargetPlatform.iOS, TargetPlatform.android]) {
        setPhoneDimensions(tester, width: 393, height: 852);

        await tester.pumpWidget(createTestApp(
          child: const HomeScreen(),
          authController: authController,
          shoppingController: shoppingController,
          platform: platform,
        ));
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.textContaining('Merhaba, Ayşe'), findsOneWidget);
        expect(find.text('Alışveriş Özeti'), findsOneWidget);
        expect(find.text('Listelerim'), findsWidgets);
        expect(find.text('Yeni Liste Aç'), findsOneWidget);

        // Tap Profile avatar
        await tester.tap(find.byIcon(Icons.eco));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Profil Bilgileri'), findsOneWidget);
        expect(find.text('Kapat'), findsOneWidget);
        await tester.tap(find.text('Kapat'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Tap Settings button in AppBar
        await tester.tap(find.byIcon(Icons.settings_outlined).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Bağlantı Ayarları'), findsOneWidget);
        await tester.tap(find.text('İptal'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Tap Yeni Liste Aç card
        await tester.ensureVisible(find.text('Yeni Liste Aç'));
        await tester.tap(find.text('Yeni Liste Aç'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Yeni Alışveriş Listesi'), findsOneWidget);

        // Cancel dialog
        await tester.tap(find.text('İptal'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      }
    });

    // 6. DASHBOARD SCREEN
    testWidgets('DashboardScreen lists, add list, and share dialog work',
        (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      setPhoneDimensions(tester, width: 393, height: 852);

      authController.setGuestUser(const User(id: '1', email: 'test@test.com', name: 'Ayşe'));
      shoppingController.fetchLists('1');
      await tester.pump(const Duration(milliseconds: 400));

      await tester.pumpWidget(createTestApp(
        child: const DashboardScreen(),
        authController: authController,
        shoppingController: shoppingController,
      ));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Yeşil Sepetim'), findsOneWidget);
      expect(find.text('Haftalık Market Alışverişi'), findsOneWidget);

      // Tap share icon on first list
      final shareBtn = find.byIcon(Icons.share_outlined).first;
      await tester.tap(shareBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Listeyi Paylaş'), findsOneWidget);
      expect(find.text('Linki Kopyala'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Tap FAB to open add list
      final fab = find.byType(FloatingActionButton);
      await tester.tap(fab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Yeni Alışveriş Listesi'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'Bahar Pikniği');
      await tester.tap(find.text('Oluştur'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.text('Bahar Pikniği'), findsOneWidget);
    });

    // 7. LIST DETAIL SCREEN
    testWidgets('ListDetailScreen item additions, categorizer, tabs & budget work',
        (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      setPhoneDimensions(tester, width: 393, height: 852);

      authController.setGuestUser(const User(id: '1', email: 'test@test.com', name: 'Ayşe'));
      shoppingController.fetchLists('1');
      await tester.pump(const Duration(milliseconds: 400));
      final listId = shoppingController.lists.first.id;

      await tester.pumpWidget(createTestApp(
        child: ListDetailScreen(listId: listId),
        authController: authController,
        shoppingController: shoppingController,
      ));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Tahmini Toplam Tutar'), findsOneWidget);
      expect(find.text('Alınacaklar (3)'), findsOneWidget);
      expect(find.text('Alındı Listesi (1)'), findsOneWidget);

      // Quick add item
      final quickAddInput = find.byType(TextField).first;
      await tester.enterText(quickAddInput, '2 kg Muz');
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Muz'), findsOneWidget);

      // Open Detailed Add Item Dialog
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      expect(find.text('Detaylı Ürün Ekle'), findsOneWidget);

      // Type product name to trigger smart categorizer in dialog
      final dlgNameField = find.widgetWithText(TextField, 'Ürün Adı');
      await tester.enterText(dlgNameField, 'Çilek');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Reyon: Manav'), findsOneWidget);

      // Cancel detailed dialog
      await tester.tap(find.text('İptal'));
      await tester.pumpAndSettle();

      // Open Smart Multi-Add Dialog (Mic icon)
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();
      expect(find.text('Sesle / Hızlı Çoklu Ekle'), findsOneWidget);
      expect(find.text('Tümünü Ekle'), findsOneWidget);
      await tester.tap(find.text('İptal'));
      await tester.pumpAndSettle();

      // Switch to Tab 2: Alındı Listesi
      await tester.tap(find.text('Alındı Listesi (1)'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.undo), findsOneWidget);
    });

    // 8. JOIN SCREEN
    testWidgets('JoinScreen loads invite info and shows join button',
        (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      setPhoneDimensions(tester, width: 393, height: 852);

      await tester.pumpWidget(createTestApp(
        child: const JoinScreen(shareCode: 'abc123'),
        authController: authController,
        shoppingController: shoppingController,
      ));

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('Bir Alışveriş Listesine Davet Edildiniz!'), findsOneWidget);
      expect(find.text('Listeye Katıl'), findsOneWidget);
    });

    // 9. SETTINGS DIALOG
    testWidgets('SettingsDialog sync switch and URL inputs operate correctly',
        (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      setPhoneDimensions(tester, width: 393, height: 852);

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const SettingsDialog(),
            ),
            child: const Text('Open Settings'),
          ),
        ),
      ));

      await tester.tap(find.text('Open Settings'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Bağlantı Ayarları'), findsOneWidget);
      expect(find.text('Sunucu Senkronizasyonu'), findsOneWidget);

      // Toggle switch
      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Sunucu Adresi (URL)'), findsOneWidget);
      await tester.tap(find.text('Kaydet'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
