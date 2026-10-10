import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/controllers.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    final authController = Provider.of<AuthController>(context, listen: false);

    if (authController.currentUser != null) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4fbf7),
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Stylized Shopping Basket & Leaf Logo
              Container(
                width: 120.0,
                height: 120.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff5eaa82).withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Main basket icon
                    const Icon(
                      Icons.shopping_basket_outlined,
                      size: 54.0,
                      color: Color(0xff5eaa82),
                    ),
                    // Small leaf icon on the top right
                    Positioned(
                      top: 32,
                      right: 32,
                      child: Container(
                        padding: const EdgeInsets.all(2.0),
                        decoration: const BoxDecoration(
                          color: Color(0xffa8e6cf),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco,
                          size: 14.0,
                          color: Color(0xff1c3d2b),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              // App Name
              const Text(
                'Yeşil Sepet',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1c3d2b),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8.0),
              // Subtitle
              const Text(
                'Kolay ve Senkronize Alışveriş',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff5a7a68),
                ),
              ),
              const SizedBox(height: 48.0),
              // Small indicator
              const SizedBox(
                width: 24.0,
                height: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff5eaa82)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
