import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class InstructorController extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  
  List<CourseModel> _courses = [];
  bool _isLoading = false;
  String? _error;

  List<CourseModel> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalStudents {
    final students = <String>{};
    for (final course in _courses) {
      students.addAll(course.enrolledStudents);
    }
    return students.length;
  }

  Future<void> loadInstructorData() async {
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

  void setCoursesStream(String instructorId) {
    _dbService.getCoursesByInstructor(instructorId).listen((courses) {
      _courses = courses;
      notifyListeners();
    });
  }

  Future<void> createCourse(CourseModel course) async {
  _setLoading(true);
  _error = null;
  
  try {
    final createdCourse = await _dbService.createCourse(course);
    
    // Auto-enroll all students from this department
    await _dbService.enrollStudentsFromDepartment(
      createdCourse.courseId,
      createdCourse.department,
    );
  } catch (e) {
    _error = e.toString();
  } finally {
    _setLoading(false);
  }
}

  Future<void> updateCourse(CourseModel course) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _dbService.updateCourse(course);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteCourse(String courseId) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _dbService.deleteCourse(courseId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<List<UserModel>> getEnrolledStudents(List<String> studentIds) async {
    return await _dbService.getEnrolledStudents(studentIds);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}