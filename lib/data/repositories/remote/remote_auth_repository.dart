import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_repository.dart';
import '../../models/user.dart';
import '../../../core/config/app_settings.dart';

/// Remote HTTP API implementation of [AuthRepository] for server sync mode.
class RemoteAuthRepository implements AuthRepository {
  @override
  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppSettings.serverUrl}/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final responseBody = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(responseBody['error'] ?? 'Giriş yapılamadı.');
    }
    return User.fromJson(responseBody['user']);
  }

  @override
  Future<User> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppSettings.serverUrl}/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    final responseBody = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(responseBody['error'] ?? 'Kayıt yapılamadı.');
    }
    return User.fromJson(responseBody['user']);
  }

  @override
  Future<String> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('${AppSettings.serverUrl}/api/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final responseBody = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(responseBody['error'] ?? 'İşlem başarısız.');
    }
    return responseBody['message'] ?? 'Şifre sıfırlama talebi alındı.';
  }
}
