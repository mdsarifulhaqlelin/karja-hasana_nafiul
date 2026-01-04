import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _userLoans = [];
  bool _isLoading = false;
  
  String? _errorMessage;
  bool _hasSearched = false;

  // ✅ নতুন মেথড যোগ করুন - ফোন ভ্যালিডেশন
  // ignore: unused_element
  bool _isValidBangladeshiPhone(String phone) {
    return RegExp(r'^01[3-9]\d{8}$').hasMatch(phone);
  }
  
  // ✅ ৩. ক্লিয়ার মেথড এখানে
  void _clearSearch() {
    _phoneController.clear();
    setState(() {
      _userLoans.clear();
      _errorMessage = null;
      _hasSearched = false;
    });
  }


  Future<void> _checkStatus() async {
    if (_phoneController.text.isEmpty) {
      setState(() {
        _errorMessage = 'মোবাইল নম্বর দিন';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _userLoans.clear();
      _hasSearched = true;
    });

    try {
      final querySnapshot = await _firestore
          .collection('loans')
          .where('phone', isEqualTo: _phoneController.text.trim())
          .orderBy('createdAt', descending: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _errorMessage = 'কোন লোন আবেদন পাওয়া যায়নি';
        });
      } else {
        setState(() {
          _userLoans = querySnapshot.docs.map((doc) {
            // ignore: unnecessary_cast
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'ত্রুটি: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'অপেক্ষমান';
      case 'approved':
        return 'অনুমোদিত';
      case 'rejected':
        return 'প্রত্যাখ্যাত';
      case 'paid':
        return 'পরিশোধিত';
      default:
        return 'অজানা';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'paid':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('লোন স্ট্যাটাস চেক'),
        backgroundColor: const Color.fromARGB(255, 231, 106, 23),
        actions: [
          if (_hasSearched) // ✅ এই কন্ডিশন
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _clearSearch,
            ),
        ],
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.blue,
              Colors.purple,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            )
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emergency contact information
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'জরুরী লোনের জন্য',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'সাইন আপ করতে কল করুন: 01770060579',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'বিকাশ করুন: 01770060579',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
          
                // Phone input section
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'আপনার লোন স্ট্যাটাস দেখতে মোবাইল নম্বর দিন',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'মোবাইল নম্বর',
                            hintText: '017XXXXXXXX',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                          maxLength: 11,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _checkStatus,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'স্ট্যাটাস চেক করুন',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          
                const SizedBox(height: 20),
          
                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
          
                // Loans list
                if (_userLoans.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'আপনার লোন আবেদনসমূহ:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._userLoans.map((loan) => _buildLoanCard(loan)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoanCard(Map<String, dynamic> loan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    loan['name'] ?? 'নাম নেই',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(loan['status'])
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(loan['status']),
                    ),
                  ),
                  child: Text(
                    _getStatusText(loan['status']),
                    style: TextStyle(
                      color: _getStatusColor(loan['status']),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.money, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  '${loan['amount']?.toString() ?? '0'} টাকা',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'আবেদনের তারিখ: ${_formatDate(loan['createdAt'])}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.date_range, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'পরিশোধের তারিখ: ${_formatDate(loan['dueDate'])}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            if (loan['voterIdNumber'] != null &&
                loan['voterIdNumber'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.badge, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'ভোটার আইডি: ${loan['voterIdNumber']}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}