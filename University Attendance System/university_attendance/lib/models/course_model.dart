class CourseModel {
  final String courseId;
  final String courseName;
  final String courseCode;
  final String instructorId;
  final String instructorName;
  final String department;
  final List<String> enrolledStudents;
  final String schedule;
  final DateTime createdAt;

  CourseModel({
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.instructorId,
    required this.instructorName,
    required this.department,
    required this.enrolledStudents,
    required this.schedule,
    required this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      courseId: json['courseId'] ?? '',
      courseName: json['courseName'] ?? '',
      courseCode: json['courseCode'] ?? '',
      instructorId: json['instructorId'] ?? '',
      instructorName: json['instructorName'] ?? '',
      department: json['department'] ?? '',
      enrolledStudents: json['enrolledStudents'] != null
          ? List<String>.from(json['enrolledStudents'])
          : [],
      schedule: json['schedule'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'courseCode': courseCode,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'department': department,
      'enrolledStudents': enrolledStudents,
      'schedule': schedule,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  CourseModel copyWith({
    String? courseId,
    String? courseName,
    String? courseCode,
    String? instructorId,
    String? instructorName,
    String? department,
    List<String>? enrolledStudents,
    String? schedule,
    DateTime? createdAt,
  }) {
    return CourseModel(
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      department: department ?? this.department,
      enrolledStudents: enrolledStudents ?? this.enrolledStudents,
      schedule: schedule ?? this.schedule,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}