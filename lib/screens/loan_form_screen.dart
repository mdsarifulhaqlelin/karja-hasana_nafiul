import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LoanFormScreen extends StatefulWidget {
  const LoanFormScreen({super.key});

  @override
  State<LoanFormScreen> createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends State<LoanFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _refController = TextEditingController();
  final TextEditingController _bKashController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _voterIdNumberController =
      TextEditingController();

  bool _isSubmitting = false;

  // Submit Form
  Future<void> _submit() async {
    // 1. Form validation
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 2. Firestore-এ লোন ডাটা সেভ
      final Map<String, dynamic> loanData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'referenceNumber': _refController.text.trim(),
        'bKashNumber': _bKashController.text.trim(),
        'voterIdNumber': _voterIdNumberController.text.trim(),
        'amount': int.parse(_amountController.text.trim()),
        'dueDate': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 3)),
        ),
        'status': 'pending',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      // Firestore-এ সেভ
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('loans')
          .add(loanData);

      print('✅ Loan saved with ID: ${docRef.id}');

      // 3. সাকসেস ডায়ালগ
      _showSuccessDialog(docRef.id);
    } catch (e) {
      print('❌ Full error: $e');
      _showSnackBar('আবেদন জমা দিতে ব্যর্থ: ${e.toString()}');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessDialog(String loanId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('✅ সফল!'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 20),
              const Text(
                'আবেদন সফলভাবে জমা হয়েছে',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // Success details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified, size: 16, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'আবেদন সংরক্ষিত',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'লোন আইডি: $loanId',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Instructions
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'পরবর্তী করণীয়:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• এডমিন আপনার আবেদন রিভিউ করবেন\n'
                      '• অ্যাডমিনের কাছ থেকে সময় শুনে টাকা ফেরত দিন\n'
                      '• কোনো সমস্যা হলে কল করুন: ০১৭৭০০৬০৫৭৯',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dialog বন্ধ
              Navigator.pop(context); // Form পেজ বন্ধ
            },
            child: const Text('ঠিক আছে'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'কর্জ নিন',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 239, 104, 46),
        foregroundColor: Colors.white,

        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue, Colors.purple],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Header
                const Icon(Icons.money_rounded, size: 60, color: Colors.green),
                const SizedBox(height: 10),
                const Text(
                  'কর্জের আবেদন ফর্ম',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 0, 0),
                  ),
                ),
                const SizedBox(height: 20),

                // Name
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'নাম *',
                    labelStyle: const TextStyle(color: Colors.red,fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    prefixIcon: const Icon(Icons.person_4,color: Colors.black,),
                    // নিচের অংশটাই shadow/transparent সমস্যা ঠিক করবে,
                    filled: true,
                    fillColor: const Color.fromARGB(255, 227, 203, 203),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'নাম লিখুন';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'মোবাইল নম্বর *',
                    labelStyle: const TextStyle(color: Colors.red,fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    prefixIcon: const Icon(Icons.phone_android,color: Colors.black,),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 227, 203, 203),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'মোবাইল নম্বর লিখুন';
                    }
                    if (value.length != 11) {
                      return '১১ ডিজিটের নম্বর লিখুন';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Reference Number
                TextFormField(
                  controller: _refController,
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'রেফারেন্স নম্বর *',
                    labelStyle: const TextStyle(color: Colors.red,fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    prefixIcon: Icon(Icons.tag,color: Colors.black,),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 227, 203, 203),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'রেফারেন্স নম্বর লিখুন';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // bKash Number
                TextFormField(
                  controller: _bKashController,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'বিকাশ নম্বর *',
                    labelStyle: const TextStyle(color: Colors.red,fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    prefixIcon: Icon(Icons.payment,color: Colors.black,),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 227, 203, 203),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'বিকাশ নম্বর লিখুন';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Amount
                TextFormField(
                  controller: _amountController,
                  style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold, fontSize: 16),
                  decoration:  InputDecoration(
                    labelText: 'টাকার পরিমাণ * (সর্বোচ্চ ২০০০)',
                    labelStyle: const TextStyle(color: Colors.red,fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    prefixIcon: Icon(Icons.money,color: Colors.black,),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 227, 203, 203),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'টাকার পরিমাণ লিখুন';
                    }
                    final amount = int.tryParse(value);
                    if (amount == null) {
                      return 'সঠিক সংখ্যা লিখুন';
                    }
                    if (amount > 2000) {
                      return 'সর্বোচ্চ ২০০০ টাকা নিতে পারেন';
                    }
                    if (amount < 100) {
                      return 'সর্বনিম্ন ১০০ টাকা হতে হবে';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Voter ID Number
                TextFormField(
                  controller: _voterIdNumberController,
                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'ভোটার আইডি নাম্বার',
                    labelStyle: const TextStyle(color: Colors.red,fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    prefixIcon: Icon(Icons.badge,color: Colors.black,),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 227, 203, 203),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: _isSubmitting
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(width: 15),
                              Text('জমা হচ্ছে...'),
                            ],
                          )
                        : const Text(
                            'আবেদন জমা দিন',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _refController.dispose();
    _bKashController.dispose();
    _amountController.dispose();
    _voterIdNumberController.dispose();
    super.dispose();
  }
}
