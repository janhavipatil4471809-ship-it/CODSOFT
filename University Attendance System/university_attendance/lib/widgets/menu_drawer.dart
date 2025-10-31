import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class MenuDrawer extends StatelessWidget {
  final UserModel user;

  const MenuDrawer({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to profile screen
            },
          ),
          if (user.role == AppConstants.roleStudent)
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('My Courses'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppConstants.courseListRoute);
              },
            ),
          if (user.role == AppConstants.roleInstructor)
  ListTile(
    leading: const Icon(Icons.class_),
    title: const Text('Manage Courses'),
    onTap: () {
      Navigator.pop(context);
      Navigator.pushNamed(context, AppConstants.manageCoursesRoute);
    },
  ),
if (user.role == AppConstants.roleInstructor)
  ListTile(
    leading: const Icon(Icons.admin_panel_settings),
    title: const Text('Admin Panel'),
    onTap: () {
      Navigator.pop(context);
      Navigator.pushNamed(context, '/admin-panel');
    },
  ),
const Divider(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to help
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () async {
              final authController = context.read<AuthController>();
              await authController.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppConstants.loginRoute,
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}