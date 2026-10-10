import 'package:flutter/material.dart';
import '../../core/config/app_settings.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/mock/mock_auth_repository.dart';
import '../../data/repositories/remote/remote_auth_repository.dart';

/// State management controller for user authentication operations.
class AuthController extends ChangeNotifier {
  final AuthRepository? _injectedAuthRepository;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthController({AuthRepository? authRepository})
      : _injectedAuthRepository = authRepository;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token => _currentUser?.id;

  AuthRepository get _authRepository =>
      _injectedAuthRepository ??
      (AppSettings.isServerSync ? RemoteAuthRepository() : MockAuthRepository());

  void setGuestUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.register(name, email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<String?> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final msg = await _authRepository.forgotPassword(email);
      _isLoading = false;
      notifyListeners();
      return msg;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
