import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/controllers.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }



  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = Provider.of<AuthController>(context, listen: false);
    final success = await authController.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage ?? 'Giriş yapılamadı.'),
          backgroundColor: const Color(0xffff9a9e),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20.0),
                // Heading & Subheading
                const Text(
                  'Hoş Geldiniz',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1c3d2b),
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Alışveriş listelerinize her yerden erişin.',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Color(0xff5a7a68),
                  ),
                ),
                const SizedBox(height: 40.0),
                // Email Field
                const Text(
                  'E-posta Adresi',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff1c3d2b),
                  ),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen e-posta adresinizi girin.';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                      return 'Geçersiz e-posta formatı.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'ornek@eposta.com',
                    prefixIcon: Icon(Icons.email_outlined, color: Color(0xff5a7a68)),
                  ),
                ),
                const SizedBox(height: 20.0),
                // Password Field
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Şifre',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff1c3d2b),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                        );
                      },
                      child: const Text(
                        'Şifremi Unuttum',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff5eaa82),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen şifrenizi girin.';
                    }
                    if (value.length < 6) {
                      return 'Şifre en az 6 karakter olmalıdır.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '••••••',
                    prefixIcon: const Icon(Icons.lock_outlined, color: Color(0xff5a7a68)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: const Color(0xff5a7a68),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
                // Submit Button
                authController.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xff5eaa82)),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Giriş Yap'),
                      ),
                const SizedBox(height: 24.0),
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Hesabınız yok mu? ',
                      style: TextStyle(color: Color(0xff5a7a68)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Kayıt Olun',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff5eaa82),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
