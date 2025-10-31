import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../models/attendance_model.dart';
import '../services/database_service.dart';
//import '../controllers/auth_controller.dart';

class StudentController extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  
  List<CourseModel> _courses = [];
  List<AttendanceModel> _attendances = [];
  bool _isLoading = false;
  String? _error;

  List<CourseModel> get courses => _courses;
  List<AttendanceModel> get attendances => _attendances;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get attendancePercentage {
    if (_attendances.isEmpty) return 0.0;
    final present = _attendances.where((a) => a.isPresent).length;
    return (present / _attendances.length) * 100;
  }

  Future<void> loadStudentData() async {
    _setLoading(true);
    _error = null;
    
    try {
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

void setCoursesStream(String studentId) {
  _dbService.getCoursesForStudent(studentId).listen((courses) {
    _courses = courses;
    notifyListeners();
  });
}

  void setAttendanceStream(String studentId) {
    _dbService.getAttendanceForStudent(studentId).listen((attendances) {
      _attendances = attendances;
      notifyListeners();
    });
  }

  Stream<List<AttendanceModel>> getAttendanceStream(
    String courseId,
    String studentId,
  ) {
    return _dbService.getAttendanceForStudent(studentId).map((attendances) {
      return attendances.where((a) => a.courseId == courseId).toList();
    });
  }

  Future<void> markAttendance(AttendanceModel attendance) async {
    try {
      await _dbService.markAttendance(attendance);
    } catch (e) {
      throw Exception('Failed to mark attendance');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}