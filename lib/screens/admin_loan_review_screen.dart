import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:karja_hasana/screens/given_loans_screen.dart';
import 'package:intl/intl.dart';

class AdminLoanReviewScreen extends StatefulWidget {
  final Map<String, dynamic> loanData;
  final String loanId;

  const AdminLoanReviewScreen({
    super.key,
    required this.loanData,
    required this.loanId,
  });

  @override
  State<AdminLoanReviewScreen> createState() => _AdminLoanReviewScreenState();
}

class _AdminLoanReviewScreenState extends State<AdminLoanReviewScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  final TextEditingController _notesController = TextEditingController();

  // Approved করলে GivenLoansScreen-এ নেভিগেট
  void _navigateToGivenLoans() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GivenLoansScreen()),
    );
  }

  // লোন Approved করা
  Future<void> _approveLoan() async {
    setState(() => _isLoading = true);

    try {
      await _firestore.collection('loans').doc(widget.loanId).update({
        'status': 'approved',
        'approvedDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'adminNotes': _notesController.text.isNotEmpty
            ? _notesController.text
            : null,
      });

      // Success message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ লোন অনুমোদন করা হয়েছে!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // GivenLoansScreen-এ নিয়ে যাওয়া
      await Future.delayed(const Duration(seconds: 1));
      _navigateToGivenLoans();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ ত্রুটি: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // লোন Reject করা
  Future<void> _rejectLoan() async {
    setState(() => _isLoading = true);

    try {
      await _firestore.collection('loans').doc(widget.loanId).update({
        'status': 'rejected',
        'rejectedDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'rejectionReason': _notesController.text.isNotEmpty
            ? _notesController.text
            : 'কোন কারণ উল্লেখ করা হয়নি',
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ লোন প্রত্যাখ্যান করা হয়েছে'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );

      // কিছুক্ষণ পর Back
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ ত্রুটি: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // তারিখ ফরম্যাট করা
  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  // ডিটেইল আইটেম
  Widget _buildDetailItem(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Icon(icon, size: 20, color: const Color.fromARGB(255, 255, 0, 0)),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 255, 81, 0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ছবি দেখানোর ডায়ালগ
  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ভোটার আইডি ছবি',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Image.network(imageUrl, fit: BoxFit.contain, height: 300),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('বন্ধ করুন'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('লোন রিভিউ -- ${widget.loanData['name'] ?? ''}'),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // User Info Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.orange,
                            radius: 30,
                            child: Text(
                              widget.loanData['name']
                                      ?.toString()
                                      .substring(0, 1)
                                      .toUpperCase() ??
                                  'U',
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.loanData['name'] ?? 'নাম নেই',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.loanData['phone'] ?? 'নম্বর নেই',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Loan Details Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'লোন তথ্য',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const Divider(),

                          _buildDetailItem(
                            'আবেদনকৃত পরিমাণ',
                            '${widget.loanData['amount']?.toString() ?? '0'} টাকা',
                            icon: Icons.money,
                          ),

                          if (widget.loanData['createdAt'] != null)
                            _buildDetailItem(
                              'আবেদনের তারিখ',
                              _formatDate(widget.loanData['createdAt']),
                              icon: Icons.calendar_today,
                            ),

                          if (widget.loanData['dueDate'] != null)
                            _buildDetailItem(
                              'পরিশোধের তারিখ',
                              _formatDate(widget.loanData['dueDate']),
                              icon: Icons.date_range,
                            ),

                          if (widget.loanData['voterIdNumber'] != null)
                            _buildDetailItem(
                              'ভোটার আইডি নম্বর',
                              widget.loanData['voterIdNumber'],
                              icon: Icons.badge,
                            ),

                          if (widget.loanData['bKashNumber'] != null)
                            _buildDetailItem(
                              'বিকাশ নম্বর',
                              widget.loanData['bKashNumber'],
                              icon: Icons.mobile_friendly,
                            ),

                          if (widget.loanData['address'] != null)
                            _buildDetailItem(
                              'ঠিকানা',
                              widget.loanData['address'],
                              icon: Icons.location_on,
                            ),

                          if (widget.loanData['purpose'] != null)
                            _buildDetailItem(
                              'করজের উদ্দেশ্য',
                              widget.loanData['purpose'],
                              icon: Icons.description,
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Voter ID Photo
                  if (widget.loanData['voterIdUrl'] != null &&
                      widget.loanData['voterIdUrl'].isNotEmpty)
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ভোটার আইডি ছবি',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 10),
                            Center(
                              child: InkWell(
                                onTap: () => _showImageDialog(
                                  context,
                                  widget.loanData['voterIdUrl'],
                                ),
                                child: Image.network(
                                  widget.loanData['voterIdUrl'],
                                  height: 200,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () => _showImageDialog(
                                  context,
                                  widget.loanData['voterIdUrl'],
                                ),
                                icon: const Icon(Icons.zoom_in),
                                label: const Text('বড় করে দেখুন'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Notes Section
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'নোট (ঐচ্ছিক)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              hintText: 'যেকোনো বিশেষ নির্দেশনা বা মন্তব্য...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Action Buttons
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'সিদ্ধান্ত নিন',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _rejectLoan,
                                  icon: const Icon(Icons.close),
                                  label: const Text('প্রত্যাখ্যান'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _approveLoan,
                                  icon: const Icon(Icons.check),
                                  label: const Text('অনুমোদন'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Note: অনুমোদন করলে করজ দেওয়ার পৃষ্ঠায় নিয়ে যাবে',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
