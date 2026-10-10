import '../models/user.dart';

/// Abstract contract for authentication data operations.
abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register(String name, String email, String password);
  Future<String> forgotPassword(String email);
}
