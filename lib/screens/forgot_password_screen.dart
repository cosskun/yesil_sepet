import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/controllers.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = Provider.of<AuthController>(context, listen: false);
    final message = await authController.forgotPassword(_emailController.text);

    if (message != null && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Color(0xff5eaa82)),
              SizedBox(width: 8.0),
              Text(
                'Şifre Sıfırlandı',
                style: TextStyle(
                  color: Color(0xff1c3d2b),
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(color: Color(0xff5a7a68), fontSize: 14.0),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to login
              },
              child: const Text('Giriş Ekranına Dön'),
            ),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage ?? 'İşlem başarısız oldu.'),
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
                const SizedBox(height: 20.0),
                const Text(
                  'Şifremi Unuttum',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1c3d2b),
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Sistemde kayıtlı e-posta adresinizi girin. Şifrenizi sıfırlayıp size geçici bir giriş şifresi tanımlayacağız.',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Color(0xff5a7a68),
                  ),
                ),
                const SizedBox(height: 40.0),
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
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
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
                const SizedBox(height: 32.0),
                authController.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xff5eaa82)),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Şifremi Sıfırla'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
