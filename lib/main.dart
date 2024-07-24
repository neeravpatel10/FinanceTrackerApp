import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/home_screen.dart';
import 'screens/add_entry_screen.dart';
import 'screens/report_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/category_screen.dart';
import 'screens/login_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(user: FirebaseAuth.instance.currentUser!),
        '/add': (context) => AddEntryScreen(),
        '/report': (context) => ReportScreen(),
        '/budget': (context) => BudgetScreen(),
        '/categories': (context) => CategoryScreen(),
      },
    );
  }
}
