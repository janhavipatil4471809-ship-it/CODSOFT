import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'controllers/student_controller.dart';
import 'controllers/instructor_controller.dart';

import 'screens/shared/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/student/course_list_screen.dart';
import 'screens/student/mark_attendance_screen.dart';
import 'screens/instructor/instructor_dashboard.dart';
import 'screens/instructor/manage_courses_screen.dart';
import 'screens/instructor/student_roster_screen.dart';
import 'screens/instructor/admin_panel_screen.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';
import 'models/course_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyACt5YYpQN_Jt0Mzh3fpF09IL6cl0PaybE',
      appId: '1:747212707875:web:bd131a7f2d10abd85bb996',
      messagingSenderId: '747212707875',
      projectId: 'university-attendance-ap-55034',
      databaseURL: 'https://university-attendance-ap-55034-default-rtdb.asia-southeast1.firebasedatabase.app',
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => StudentController()),
        ChangeNotifierProvider(create: (_) => InstructorController()),
      ],
      child: Consumer<AuthController>(
        builder: (context, authController, child) {
          // Set up streams when user is logged in
          if (authController.currentUser != null) {
            final user = authController.currentUser!;
            
            if (user.role == AppConstants.roleStudent) {
              context.read<StudentController>().setCoursesStream(user.uid);
              context.read<StudentController>().setAttendanceStream(user.uid);
            } else {
              context.read<InstructorController>().setCoursesStream(user.uid);
            }
          }

          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: AppConstants.splashRoute,
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case AppConstants.splashRoute:
                  return MaterialPageRoute(
                    builder: (_) => const SplashScreen(),
                  );
                case AppConstants.loginRoute:
                  return MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  );
                case AppConstants.registerRoute:
                  return MaterialPageRoute(
                    builder: (_) => const RegisterScreen(),
                  );
                case AppConstants.studentDashboardRoute:
                  return MaterialPageRoute(
                    builder: (_) => const StudentDashboard(),
                  );
                case AppConstants.courseListRoute:
                  return MaterialPageRoute(
                    builder: (_) => const CourseListScreen(),
                  );
                case AppConstants.markAttendanceRoute:
                  final course = settings.arguments as CourseModel;
                  return MaterialPageRoute(
                    builder: (_) => MarkAttendanceScreen(course: course),
                  );
                case AppConstants.instructorDashboardRoute:
                  return MaterialPageRoute(
                    builder: (_) => const InstructorDashboard(),
                  );
                case AppConstants.manageCoursesRoute:
                  return MaterialPageRoute(
                    builder: (_) => const ManageCoursesScreen(),
                  );
                case AppConstants.studentRosterRoute:
                  final course = settings.arguments as CourseModel;
                  return MaterialPageRoute(
                    builder: (_) => StudentRosterScreen(course: course),
                  );
                case '/admin-panel':
  return MaterialPageRoute(
    builder: (_) => const AdminPanelScreen(),
  );
                default:
                  return MaterialPageRoute(
                    builder: (_) => const SplashScreen(),
                  );
              }
            },
          );
        },
      ),
    );
  }
}