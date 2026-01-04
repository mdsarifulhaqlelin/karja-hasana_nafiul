import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Bottom NavigationBer

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // <-- Bottom Navigation current index
    });
    // User Form
    if (index == 0) {
      Navigator.pushNamed(context, '/User_Screen');
    }
    // শুধু Admin জন্য
    else if (index == 1) {
      Navigator.pushNamed(context, '/admin_login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ড্যাশবোর্ড',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(185, 137, 64, 255),
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFBC2EB), // Soft Pink
      Color(0xFFA6C1EE), // Soft Blue/Purple
    ],
  ),
),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // homeScreen => moved => lone_form
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/loan_form'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  textStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)
                ),
                child: const Text('**কর্জ নিন**'),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/About_Admin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)
                ),
                child: const Text('আমাদের সম্পর্কে জানুন'),
              ),
            ],
          ),
        ),
      ),
      // 👇 Added Bottom Navigation Only,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}
