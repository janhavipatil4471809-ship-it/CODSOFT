import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'University Attendance';
  static const String appVersion = '1.0.0';

  // Routes
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String studentDashboardRoute = '/student-dashboard';
  static const String instructorDashboardRoute = '/instructor-dashboard';
  static const String courseListRoute = '/courses';
  static const String markAttendanceRoute = '/mark-attendance';
  static const String manageCoursesRoute = '/manage-courses';
  static const String studentRosterRoute = '/student-roster';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String coursesCollection = 'courses';
  static const String attendanceCollection = 'attendance';

  // User Roles
  static const String roleStudent = 'student';
  static const String roleInstructor = 'instructor';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;

  // Error Messages
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorInvalidPassword = 'Password must be at least 6 characters.';
  static const String errorUserNotFound = 'User not found.';
  static const String errorWrongPassword = 'Incorrect password.';
  static const String errorEmailInUse = 'Email already in use.';
  static const String errorWeakPassword = 'Password is too weak.';
  static const String errorGeneric = 'An error occurred. Please try again.';
}

class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color secondary = Color(0xFF10B981);
  static const Color accent = Color(0xFFF59E0B);
  
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  
  static const Color divider = Color(0xFFE5E7EB);
  static const Color disabled = Color(0xFFD1D5DB);
}