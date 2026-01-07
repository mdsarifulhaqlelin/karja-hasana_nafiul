import 'package:flutter/material.dart';
import 'package:karja_hasana/screens/admin_home_screen.dart';


class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  void _login() {
    final id = _idController.text.trim();
    final password = _passwordController.text.trim();
    if (id.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'আইডি এবং পাসওয়ার্ড দিন';
      });
      return;
    }
    if (id == '926219' && password == '01770060579') {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      // Simulate login process
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
        );
      });
    } else {
      setState(() {
        _errorMessage = 'ভুল আইডি বা পাসওয়ার্ড';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('প্রশাসক পর্দা'),
        backgroundColor: const Color.fromARGB(255, 243, 135, 4),
        
      ),
      body: Container(
        decoration: const BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF746BAE), // Soft Pink
      Color(0xFF5E7CF1), // Soft Blue/Purple
    ],
  ),
),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30.00),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_home_outlined,
                        size: 80,
                        color: Color.fromARGB(255, 255, 115, 0),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'প্রশাসক লগইন',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _idController,
                        decoration: const InputDecoration(
                          labelText: 'আইডি',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'পাসওয়ার্ড',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      if (_errorMessage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 245, 126, 15),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'লগইন',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
