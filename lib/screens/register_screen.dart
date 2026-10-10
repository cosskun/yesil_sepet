import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/controllers.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = Provider.of<AuthController>(context, listen: false);
    final success = await authController.register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      // Otomatik giriş yapmaması için kullanıcı oturumunu temizliyoruz
      authController.logout();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kayıt başarılı! Giriş yapmak için bilgilerinizi giriniz.'),
          backgroundColor: Color(0xff5eaa82),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Giriş sayfasına geri yönlendiriyoruz (pop yapıyoruz)
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage ?? 'Kayıt başarısız oldu.'),
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20.0),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10.0),
                const Text(
                  'Yeni Hesap Oluştur',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1c3d2b),
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Alışverişlerinizi eşitlemek ve kaydetmek için kaydolun.',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Color(0xff5a7a68),
                  ),
                ),
                const SizedBox(height: 30.0),
                // Name Field
                const Text(
                  'Adınız Soyadınız',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff1c3d2b),
                  ),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen adınızı girin.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Ahmet Yılmaz',
                    prefixIcon: Icon(Icons.person_outline, color: Color(0xff5a7a68)),
                  ),
                ),
                const SizedBox(height: 16.0),
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
                    hintText: 'ahmet@eposta.com',
                    prefixIcon: Icon(Icons.email_outlined, color: Color(0xff5a7a68)),
                  ),
                ),
                const SizedBox(height: 16.0),
                // Password Field
                const Text(
                  'Şifre',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff1c3d2b),
                  ),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir şifre girin.';
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
                const SizedBox(height: 16.0),
                // Confirm Password Field
                const Text(
                  'Şifre Tekrarı',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff1c3d2b),
                  ),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen şifrenizi tekrar girin.';
                    }
                    if (value != _passwordController.text) {
                      return 'Şifreler eşleşmiyor.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: '••••••',
                    prefixIcon: Icon(Icons.lock_clock_outlined, color: Color(0xff5a7a68)),
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
                        child: const Text('Kayıt Ol'),
                      ),
                const SizedBox(height: 24.0),
                // Back to Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Zaten hesabınız var mı? ',
                      style: TextStyle(color: Color(0xff5a7a68)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Giriş Yapın',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff5eaa82),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
