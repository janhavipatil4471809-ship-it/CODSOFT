import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/student_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/course_model.dart';
import '../../models/attendance_model.dart';
import '../../utils/constants.dart';
import '../../widgets/attendance_card.dart';

class MarkAttendanceScreen extends StatelessWidget {
  final CourseModel course;

  const MarkAttendanceScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final studentController = context.watch<StudentController>();
    final user = authController.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.courseName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course.courseCode,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(course.instructorName),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(course.schedule),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your instructor will mark your attendance during class',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Attendance History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<AttendanceModel>>(
              stream: studentController.getAttendanceStream(
                course.courseId,
                user?.uid ?? '',
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final attendances = snapshot.data ?? [];
                
                if (attendances.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 48,
                              color: AppColors.textLight,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No attendance records yet',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // Calculate statistics
                final totalClasses = attendances.length;
                final presentCount = attendances.where((a) => a.isPresent).length;
                final percentage = (presentCount / totalClasses * 100).toStringAsFixed(1);

                return Column(
                  children: [
                    Card(
                      color: AppColors.primary.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat('Total', totalClasses.toString(), Icons.calendar_today),
                            _buildStat('Present', presentCount.toString(), Icons.check_circle, AppColors.success),
                            _buildStat('Absent', (totalClasses - presentCount).toString(), Icons.cancel, AppColors.error),
                            _buildStat('Rate', '$percentage%', Icons.analytics, AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ...attendances.map((attendance) {
                      return AttendanceCard(attendance: attendance);
                    }).toList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, [Color? color]) {
    return Column(
      children: [
        Icon(icon, color: color ?? AppColors.textSecondary, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}