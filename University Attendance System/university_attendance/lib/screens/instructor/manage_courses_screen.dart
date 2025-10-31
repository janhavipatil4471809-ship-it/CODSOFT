import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/instructor_controller.dart';
import '../../models/course_model.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class ManageCoursesScreen extends StatefulWidget {
  const ManageCoursesScreen({super.key});

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  void _showAddCourseDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final scheduleController = TextEditingController();
    final departmentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Course'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Course Name',
                  hint: 'e.g., Introduction to Programming',
                  controller: nameController,
                  validator: (value) => Validators.validateRequired(value, 'Course name'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Course Code',
                  hint: 'e.g., CS101',
                  controller: codeController,
                  validator: (value) => Validators.validateRequired(value, 'Course code'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Schedule',
                  hint: 'e.g., Mon/Wed 10:00 AM',
                  controller: scheduleController,
                  validator: (value) => Validators.validateRequired(value, 'Schedule'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Department',
                  hint: 'e.g., Computer Science',
                  controller: departmentController,
                  validator: (value) => Validators.validateRequired(value, 'Department'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<InstructorController>(
            builder: (context, controller, child) {
              return CustomButton(
                text: 'Add',
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final authController = context.read<AuthController>();
                    final user = authController.currentUser!;

                    final course = CourseModel(
                      courseId: '',
                      courseName: nameController.text.trim(),
                      courseCode: codeController.text.trim(),
                      instructorId: user.uid,
                      instructorName: user.name,
                      department: departmentController.text.trim(),
                      enrolledStudents: [],
                      schedule: scheduleController.text.trim(),
                      createdAt: DateTime.now(),
                    );

                    await controller.createCourse(course);
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Course created successfully'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  }
                },
                isLoading: controller.isLoading,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Courses'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCourseDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<InstructorController>(
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
                    'No courses yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _showAddCourseDialog,
                    child: Text('Create Your First Course'),
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
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    course.courseName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(course.courseCode),
                      Text(
                        '${course.enrolledStudents.length} students • ${course.schedule}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(Icons.people, size: 20),
                            SizedBox(width: 8),
                            Text('View Students'),
                          ],
                        ),
                        onTap: () {
                          Future.delayed(Duration.zero, () {
                            Navigator.pushNamed(
                              context,
                              AppConstants.studentRosterRoute,
                              arguments: course,
                            );
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: AppColors.error),
                            SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                        onTap: () async {
                          await controller.deleteCourse(course.courseId);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppConstants.studentRosterRoute,
                      arguments: course,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}