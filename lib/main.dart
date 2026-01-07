import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karja_hasana/screens/admin_home_screen.dart';
import 'package:karja_hasana/screens/adminloginScreen.dart';
import 'screens/aboutAdminScreen.dart';
import 'screens/homeScreen.dart';
import 'screens/loan_form_screen.dart';
import 'screens/loan_list_screen.dart';
import 'screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/user_Screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase initialize (VERY IMPORTANT)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Debug: বকেট নাম প্রিন্ট করুন
  print('📦 Storage Bucket: ${FirebaseStorage.instance.bucket}');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'কর্জে হাসানাহ',
      theme: ThemeData(
        textTheme: GoogleFonts.notoSansBengaliTextTheme(),
        // <-- লাইট থিম
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // AppBar এর জন্য হালকা রং
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.black,
        ),
      ),
      // <-- ডার্ক থিম,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/HomeScreen': (context) => HomeScreen(),
        '/loan_form': (context) => LoanFormScreen(),
        '/About_Admin': (context) => Aboutadminscreen(),
        '/Admin_Main': (context) => AdminHomeScreen(),
        '/User_Screen': (context) => UserScreen(),
        '/loan_list': (context) => LoanListScreen(),
        '/admin_login' : (context) => AdminLoginScreen(),
      },
    );
  }
}
