import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/controllers.dart';
import 'theme/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/join_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Suppress yellow-black zebra stripe overflow warnings across all devices
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const SizedBox.shrink();
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ShoppingController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  String? _extractShareCode() {
    final uri = Uri.base;
    // Check fragment e.g. #/join/code or #join=code
    if (uri.fragment.contains('join')) {
      final parts = uri.fragment.split('/');
      if (parts.length >= 3 && parts[1] == 'join') {
        return parts[2];
      }
      final queryParam = Uri.tryParse(uri.fragment)?.queryParameters['join'];
      if (queryParam != null && queryParam.isNotEmpty) {
        return queryParam;
      }
    }
    // Check query parameter e.g. ?join=code
    if (uri.queryParameters.containsKey('join')) {
      return uri.queryParameters['join'];
    }
    // Check path segments e.g. /join/code
    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[0] == 'join') {
      return segments[1];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final shareCode = _extractShareCode();

    return MaterialApp(
      title: 'Yeşil Sepet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: shareCode != null && shareCode.isNotEmpty
          ? JoinScreen(shareCode: shareCode)
          : const SplashScreen(),
    );
  }
}
