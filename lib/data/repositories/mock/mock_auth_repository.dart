import '../auth_repository.dart';
import '../../models/user.dart';

/// In-memory mock implementation of [AuthRepository] for offline mode.
class MockAuthRepository implements AuthRepository {
  static final List<Map<String, String>> _mockUsers = [
    {
      'id': '1',
      'name': 'Deneme Kullanıcı',
      'email': 'test@test.com',
      'password': 'password123'
    }
  ];

  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final userMap = _mockUsers.firstWhere(
      (u) => u['email'] == email.trim() && u['password'] == password,
      orElse: () => throw Exception('E-posta veya şifre hatalı.'),
    );
    return User(id: userMap['id']!, email: userMap['email']!, name: userMap['name']!);
  }

  @override
  Future<User> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (_mockUsers.any((u) => u['email'] == email.trim())) {
      throw Exception(
          'Böyle bir üyelik bulunmaktadır. Şifrenizi unuttuysanız lütfen şifremi unuttum bölümünden şifrenizi yenileyiniz.');
    }
    final newId = (DateTime.now().millisecondsSinceEpoch).toString();
    final newUser = {
      'id': newId,
      'name': name.trim(),
      'email': email.trim(),
      'password': password
    };
    _mockUsers.add(newUser);
    return User(id: newId, email: newUser['email']!, name: newUser['name']!);
  }

  @override
  Future<String> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final exists = _mockUsers.any((u) => u['email'] == email.trim());
    if (!exists) {
      throw Exception('Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.');
    }
    return 'Şifreniz geçici olarak "123456" yapıldı. Giriş yaptıktan sonra değiştirebilirsiniz.';
  }
}
