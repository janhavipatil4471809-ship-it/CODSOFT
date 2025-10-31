class AttendanceModel {
  final String attendanceId;
  final String courseId;
  final String studentId;
  final String studentName;
  final DateTime date;
  final bool isPresent;
  final String? remarks;
  final DateTime markedAt;

  AttendanceModel({
    required this.attendanceId,
    required this.courseId,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.isPresent,
    this.remarks,
    required this.markedAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      attendanceId: json['attendanceId'] ?? '',
      courseId: json['courseId'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      isPresent: json['isPresent'] ?? false,
      remarks: json['remarks'],
      markedAt: json['markedAt'] != null
          ? DateTime.parse(json['markedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendanceId': attendanceId,
      'courseId': courseId,
      'studentId': studentId,
      'studentName': studentName,
      'date': date.toIso8601String(),
      'isPresent': isPresent,
      'remarks': remarks,
      'markedAt': markedAt.toIso8601String(),
    };
  }
}