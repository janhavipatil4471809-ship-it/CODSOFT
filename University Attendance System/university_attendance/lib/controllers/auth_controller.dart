import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<UserModel?> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? studentId,
    String? department,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      final user = await _authService.register(
        email: email,
        password: password,
        name: name,
        role: role,
        studentId: studentId,
        department: department,
      );
      
      _currentUser = user;
      return user;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<UserModel?> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    
    try {
      final user = await _authService.login(email, password);
      _currentUser = user;
      return user;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authService.logout();
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      _currentUser = await _authService.getCurrentUserData();
      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}