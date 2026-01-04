import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // 3 সেকেন্ড পরে হোম পেজে যাবে
    Timer(const Duration(seconds: 5), () {
      // routes option ==> main.dart ==> Splash ==> homescreen
      Navigator.pushReplacementNamed(context, '/HomeScreen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // অ্যাপ লোগো
            // const FlutterLogo(size: 110,),
            Image.asset('assets/icons/icon.png', width: 110, height: 110, fit: BoxFit.contain),

            const SizedBox(height: 25),

            // App Name,
            
            const Text(
              "কর্জে হাসানাহ",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrangeAccent,
              ),
            ),
            const SizedBox(height: 10),
            // Loading Animation,
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
