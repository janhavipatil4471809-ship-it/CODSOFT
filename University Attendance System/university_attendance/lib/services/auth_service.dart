import 'package:firebase_auth/firebase_auth.dart';
import 'package:university_attendance/models/user_model.dart';
import 'database_service.dart';
import 'error_handler.dart';
import 'security_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _dbService = DatabaseService();
  final SecurityService _securityService = SecurityService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register new user
  // Register new user
Future<UserModel?> register({
  required String email,
  required String password,
  required String name,
  required String role,
  String? studentId,
  String? department,
}) async {
  try {
    final sanitizedEmail = _securityService.sanitizeInput(email.toLowerCase());
    final sanitizedName = _securityService.sanitizeInput(name);
    
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: sanitizedEmail,
      password: password,
    );

    final user = UserModel(
      uid: userCredential.user!.uid,
      email: sanitizedEmail,
      name: sanitizedName,
      role: role,
      studentId: studentId,
      department: department,
      createdAt: DateTime.now(),
    );

    await _dbService.createUser(user);
    await userCredential.user!.updateDisplayName(sanitizedName);

    // Auto-enroll student in department courses
    if (role == 'student' && department != null && department.isNotEmpty) {
      await _dbService.autoEnrollStudentByDepartment(user.uid, department);
    }

    return user;
  } catch (e) {
    ErrorHandler.logError('register', e);
    throw Exception(ErrorHandler.getErrorMessage(e));
  }
}

  // Login user
  Future<UserModel?> login(String email, String password) async {
    try {
      final sanitizedEmail = _securityService.sanitizeInput(email.toLowerCase());
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: sanitizedEmail,
        password: password,
      );

      return await _dbService.getUser(userCredential.user!.uid);
    } catch (e) {
      ErrorHandler.logError('login', e);
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _securityService.clearAllSecureData();
      await _auth.signOut();
    } catch (e) {
      ErrorHandler.logError('logout', e);
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      return await _dbService.getUser(user.uid);
    } catch (e) {
      ErrorHandler.logError('getCurrentUserData', e);
      return null;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      ErrorHandler.logError('resetPassword', e);
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }
}