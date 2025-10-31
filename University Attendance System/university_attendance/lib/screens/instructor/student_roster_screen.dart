import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../controllers/instructor_controller.dart';
import '../../models/course_model.dart';
import '../../models/user_model.dart';
import '../../models/attendance_model.dart';
import '../../utils/constants.dart';
import '../../services/database_service.dart';

class StudentRosterScreen extends StatefulWidget {
  final CourseModel course;

  const StudentRosterScreen({super.key, required this.course});

  @override
  State<StudentRosterScreen> createState() => _StudentRosterScreenState();
}

class _StudentRosterScreenState extends State<StudentRosterScreen> {
  List<UserModel> _students = [];
  bool _isLoading = true;
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    
    final controller = context.read<InstructorController>();
    final students = await controller.getEnrolledStudents(
      widget.course.enrolledStudents,
    );
    
    setState(() {
      _students = students;
      _isLoading = false;
    });
  }

  void _showMarkAttendanceDialog(UserModel student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark Attendance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: Text(
                student.name[0].toUpperCase(),
                style: TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            SizedBox(height: 16),
            Text(
              student.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              student.studentId ?? student.email,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: 24),
            Text(
              'Mark attendance for today',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _markAttendance(student, false),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Absent'),
          ),
          ElevatedButton(
            onPressed: () => _markAttendance(student, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: Text('Present'),
          ),
        ],
      ),
    );
  }

  Future<void> _markAttendance(UserModel student, bool isPresent) async {
    try {
      final attendance = AttendanceModel(
        attendanceId: const Uuid().v4(),
        courseId: widget.course.courseId,
        studentId: student.uid,
        studentName: student.name,
        date: DateTime.now(),
        isPresent: isPresent,
        markedAt: DateTime.now(),
      );

      await _dbService.markAttendance(attendance);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attendance marked: ${isPresent ? "Present" : "Absent"}'),
            backgroundColor: isPresent ? AppColors.success : AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark attendance'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showEnrollStudentDialog() {
    final studentIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enroll Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the student\'s UID to enroll them in ${widget.course.courseCode}',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: studentIdController,
              decoration: InputDecoration(
                labelText: 'Student UID',
                hintText: 'Paste student UID here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final studentId = studentIdController.text.trim();
              if (studentId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a student UID')),
                );
                return;
              }

              try {
                await _dbService.enrollStudent(widget.course.courseId, studentId);
                Navigator.pop(context);
                _loadStudents();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Student enrolled successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Enroll'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Roster'),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: _showEnrollStudentDialog,
            tooltip: 'Enroll Student',
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.course.courseName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.course.courseCode,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.course.enrolledStudents.length} Enrolled Students',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Tap on a student to mark attendance',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No students enrolled yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + icon to enroll students',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  student.name[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                student.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(student.email),
                                  if (student.studentId != null)
                                    Text(
                                      'ID: ${student.studentId}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Icon(
                                Icons.check_circle_outline,
                                color: AppColors.primary,
                              ),
                              onTap: () => _showMarkAttendanceDialog(student),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}