import 'package:firebase_auth/firebase_auth.dart';
import 'package:university_attendance/utils/constants.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return AppConstants.errorUserNotFound;
        case 'wrong-password':
          return AppConstants.errorWrongPassword;
        case 'email-already-in-use':
          return AppConstants.errorEmailInUse;
        case 'weak-password':
          return AppConstants.errorWeakPassword;
        case 'invalid-email':
          return AppConstants.errorInvalidEmail;
        case 'network-request-failed':
          return AppConstants.errorNetwork;
        default:
          return error.message ?? AppConstants.errorGeneric;
      }
    }
    
    return error.toString().isEmpty 
        ? AppConstants.errorGeneric 
        : error.toString();
  }

  static void logError(String operation, dynamic error, [StackTrace? stackTrace]) {
    print('Error in $operation: $error');
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
  }
}