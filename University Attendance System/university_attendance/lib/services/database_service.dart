import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/attendance_model.dart';
import '../utils/constants.dart';
import 'error_handler.dart';

class DatabaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final Uuid _uuid = const Uuid();

  // User operations
  Future<void> createUser(UserModel user) async {
    try {
      await _db.ref('${AppConstants.usersCollection}/${user.uid}').set(user.toJson());
    } catch (e) {
      ErrorHandler.logError('createUser', e);
      throw Exception('Failed to create user');
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final snapshot = await _db.ref('${AppConstants.usersCollection}/$uid').get();
      if (snapshot.exists) {
        return UserModel.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
      }
      return null;
    } catch (e) {
      ErrorHandler.logError('getUser', e);
      return null;
    }
  }

  // Course operations
  Future<CourseModel> createCourse(CourseModel course) async {
    try {
      final courseId = _uuid.v4();
      final newCourse = course.copyWith(
        courseId: courseId,
        createdAt: DateTime.now(),
      );
      
      await _db.ref('${AppConstants.coursesCollection}/$courseId').set(newCourse.toJson());
      return newCourse;
    } catch (e) {
      ErrorHandler.logError('createCourse', e);
      throw Exception('Failed to create course');
    }
  }

  Future<void> updateCourse(CourseModel course) async {
    try {
      await _db.ref('${AppConstants.coursesCollection}/${course.courseId}')
          .update(course.toJson());
    } catch (e) {
      ErrorHandler.logError('updateCourse', e);
      throw Exception('Failed to update course');
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await _db.ref('${AppConstants.coursesCollection}/$courseId').remove();
    } catch (e) {
      ErrorHandler.logError('deleteCourse', e);
      throw Exception('Failed to delete course');
    }
  }

  Stream<List<CourseModel>> getCoursesByInstructor(String instructorId) {
    return _db.ref(AppConstants.coursesCollection)
        .orderByChild('instructorId')
        .equalTo(instructorId)
        .onValue
        .map((event) {
      final courses = <CourseModel>[];
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          courses.add(CourseModel.fromJson(Map<String, dynamic>.from(value)));
        });
      }
      return courses;
    });
  }

  Stream<List<CourseModel>> getCoursesForStudent(String studentId) {
    return _db.ref(AppConstants.coursesCollection).onValue.map((event) {
      final courses = <CourseModel>[];
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          final course = CourseModel.fromJson(Map<String, dynamic>.from(value));
          if (course.enrolledStudents.contains(studentId)) {
            courses.add(course);
          }
        });
      }
      return courses;
    });
  }

  Stream<List<CourseModel>> getAllCourses() {
  return _db.ref(AppConstants.coursesCollection).onValue.map((event) {
    final courses = <CourseModel>[];
    if (event.snapshot.value != null) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      data.forEach((key, value) {
        courses.add(CourseModel.fromJson(Map<String, dynamic>.from(value)));
      });
    }
    return courses;
  });
}

  Future<void> enrollStudent(String courseId, String studentId) async {
    try {
      final snapshot = await _db.ref('${AppConstants.coursesCollection}/$courseId').get();
      if (snapshot.exists) {
        final course = CourseModel.fromJson(
          Map<String, dynamic>.from(snapshot.value as Map)
        );
        
        if (!course.enrolledStudents.contains(studentId)) {
          final updatedStudents = [...course.enrolledStudents, studentId];
          await _db.ref('${AppConstants.coursesCollection}/$courseId/enrolledStudents')
              .set(updatedStudents);
        }
      }
    } catch (e) {
      ErrorHandler.logError('enrollStudent', e);
      throw Exception('Failed to enroll student');
    }
  }

  // Attendance operations
  Future<void> markAttendance(AttendanceModel attendance) async {
    try {
      await _db.ref('${AppConstants.attendanceCollection}/${attendance.attendanceId}')
          .set(attendance.toJson());
    } catch (e) {
      ErrorHandler.logError('markAttendance', e);
      throw Exception('Failed to mark attendance');
    }
  }

  Stream<List<AttendanceModel>> getAttendanceForCourse(String courseId) {
    return _db.ref(AppConstants.attendanceCollection)
        .orderByChild('courseId')
        .equalTo(courseId)
        .onValue
        .map((event) {
      final attendances = <AttendanceModel>[];
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          attendances.add(
            AttendanceModel.fromJson(Map<String, dynamic>.from(value))
          );
        });
      }
      return attendances;
    });
  }

  Stream<List<AttendanceModel>> getAttendanceForStudent(String studentId) {
    return _db.ref(AppConstants.attendanceCollection)
        .orderByChild('studentId')
        .equalTo(studentId)
        .onValue
        .map((event) {
      final attendances = <AttendanceModel>[];
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          attendances.add(
            AttendanceModel.fromJson(Map<String, dynamic>.from(value))
          );
        });
      }
      return attendances;
    });
  }

  // Enroll all students from a department into a course
Future<void> enrollStudentsFromDepartment(String courseId, String department) async {
  try {
    final snapshot = await _db.ref(AppConstants.usersCollection).get();
    
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      
      for (var entry in data.entries) {
        final user = UserModel.fromJson(Map<String, dynamic>.from(entry.value));
        
        // If user is a student and from same department
        if (user.role == AppConstants.roleStudent &&
            user.department?.toLowerCase() == department.toLowerCase()) {
          await enrollStudent(courseId, user.uid);
        }
      }
    }
  } catch (e) {
    ErrorHandler.logError('enrollStudentsFromDepartment', e);
  }
}

  Future<List<UserModel>> getEnrolledStudents(List<String> studentIds) async {
    try {
      final students = <UserModel>[];
      for (final id in studentIds) {
        final user = await getUser(id);
        if (user != null && user.role == AppConstants.roleStudent) {
          students.add(user);
        }
      }
      return students;
    } catch (e) {
      ErrorHandler.logError('getEnrolledStudents', e);
      return [];
    }
  }

  // Get all users (for admin)
Future<List<UserModel>> getAllUsers() async {
  try {
    final snapshot = await _db.ref(AppConstants.usersCollection).get();
    
    if (!snapshot.exists) return [];
    
    final users = <UserModel>[];
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    
    data.forEach((key, value) {
      users.add(UserModel.fromJson(Map<String, dynamic>.from(value)));
    });
    
    return users;
  } catch (e) {
    ErrorHandler.logError('getAllUsers', e);
    return [];
  }
}

// Delete user by admin (doesn't require authentication)
Future<void> deleteUserByAdmin(String uid) async {
  try {
    // Delete user record
    await _db.ref('${AppConstants.usersCollection}/$uid').remove();

    // Delete user's attendance records
    final attendanceSnapshot = await _db.ref(AppConstants.attendanceCollection).get();
    if (attendanceSnapshot.exists) {
      final data = Map<String, dynamic>.from(attendanceSnapshot.value as Map);
      final toDelete = <String>[];
      
      data.forEach((key, value) {
        final attendance = AttendanceModel.fromJson(Map<String, dynamic>.from(value));
        if (attendance.studentId == uid) {
          toDelete.add(key);
        }
      });
      
      for (var key in toDelete) {
        await _db.ref('${AppConstants.attendanceCollection}/$key').remove();
      }
    }

    // Remove student from enrolled courses OR delete instructor's courses
    final coursesSnapshot = await _db.ref(AppConstants.coursesCollection).get();
    if (coursesSnapshot.exists) {
      final data = Map<String, dynamic>.from(coursesSnapshot.value as Map);
      final coursesToDelete = <String>[];
      
      for (var entry in data.entries) {
        final course = CourseModel.fromJson(Map<String, dynamic>.from(entry.value));
        
        // If instructor, delete their courses
        if (course.instructorId == uid) {
          coursesToDelete.add(course.courseId);
        }
        // If student, remove from enrolled list
        else if (course.enrolledStudents.contains(uid)) {
          final updatedStudents = course.enrolledStudents.where((id) => id != uid).toList();
          await _db.ref('${AppConstants.coursesCollection}/${course.courseId}/enrolledStudents')
              .set(updatedStudents);
        }
      }
      
      // Delete instructor's courses
      for (var courseId in coursesToDelete) {
        await _db.ref('${AppConstants.coursesCollection}/$courseId').remove();
      }
    }
  } catch (e) {
    ErrorHandler.logError('deleteUserByAdmin', e);
    throw Exception('Failed to delete user');
  }
}

  Stream<List<CourseModel>> getCoursesByDepartment(String department) {
  return _db.ref(AppConstants.coursesCollection).onValue.map((event) {
    final courses = <CourseModel>[];
    if (event.snapshot.value != null) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      data.forEach((key, value) {
        final course = CourseModel.fromJson(Map<String, dynamic>.from(value));
        if (course.department.toLowerCase() == department.toLowerCase()) {
          courses.add(course);
        }
      });
    }
    return courses;
  });
}

// Auto-enroll student in all department courses
Future<void> autoEnrollStudentByDepartment(String studentId, String department) async {
  try {
    final snapshot = await _db.ref(AppConstants.coursesCollection).get();
    
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      
      for (var entry in data.entries) {
        final course = CourseModel.fromJson(Map<String, dynamic>.from(entry.value));
        
        // If course is in same department and student not already enrolled
        if (course.department.toLowerCase() == department.toLowerCase() &&
            !course.enrolledStudents.contains(studentId)) {
          await enrollStudent(course.courseId, studentId);
        }
      }
    }
  } catch (e) {
    ErrorHandler.logError('autoEnrollStudentByDepartment', e);
  }
}
}