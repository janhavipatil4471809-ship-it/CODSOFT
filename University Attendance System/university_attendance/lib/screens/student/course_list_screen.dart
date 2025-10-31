import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/student_controller.dart';
import '../../utils/constants.dart';
import '../../widgets/course_tile.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
      ),
      body: Consumer<StudentController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 80,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No courses available',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.courses.length,
            itemBuilder: (context, index) {
              final course = controller.courses[index];
              return CourseTile(
                course: course,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppConstants.markAttendanceRoute,
                    arguments: course,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}