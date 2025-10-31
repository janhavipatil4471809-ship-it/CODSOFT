import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/alarm_service.dart';
import 'screens/home_screen.dart';
import 'screens/alarm_ring_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AlarmService(),
      child: MaterialApp(
        title: 'Alarm Clock',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF4A90E2),
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4A90E2),
            brightness: Brightness.light,
          ),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: const AlarmChecker(),
      ),
    );
  }
}

class AlarmChecker extends StatefulWidget {
  const AlarmChecker({Key? key}) : super(key: key);

  @override
  State<AlarmChecker> createState() => _AlarmCheckerState();
}

class _AlarmCheckerState extends State<AlarmChecker> {
  @override
  void initState() {
    super.initState();
    _startAlarmChecker();
  }

  void _startAlarmChecker() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _checkAlarms();
        _startAlarmChecker();
      }
    });
  }

  void _checkAlarms() {
    final alarmService = Provider.of<AlarmService>(context, listen: false);
    final now = DateTime.now();
    
    for (final alarm in alarmService.alarms) {
      if (alarm.isActive) {
        final alarmTime = alarm.time;
        
        if (alarmTime.hour == now.hour && 
            alarmTime.minute == now.minute &&
            now.second < 5) {
          
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AlarmRingScreen(alarm: alarm),
              fullscreenDialog: true,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}