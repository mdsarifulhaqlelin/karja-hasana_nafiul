import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:karja_hasana/screens/edit_loan_screen.dart';

class LoanDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> loanData;
  final String loanId;

  const LoanDetailsScreen({
    super.key,
    required this.loanData,
    required this.loanId,
  });

  // টাইমস্ট্যাম্প থেকে ডেটটাইম কনভার্ট
  DateTime? _getDateTimeFromTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return null;
  }

  // ফর্ম্যাটেড ডেট টাইম
  String _formatDateTime(DateTime? date) {
    if (date == null) return 'তারিখ নেই';
    return DateFormat('d/M/yyyy h:mm a').format(date);
  }

  // ফর্ম্যাটেড তারিখ
  String _formatDate(DateTime? date) {
    if (date == null) return 'তারিখ নেই';
    return DateFormat('d/M/yyyy').format(date);
  }

  // স্ট্যাটাস কালার
  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'given':
        return Colors.purple;
      case 'paid':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  // স্ট্যাটাস টেক্সট
  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'অনুমোদিত';
      case 'given':
        return 'কর্জ দেওয়া হয়েছে';
      case 'paid':
        return 'পরিশোধিত';
      case 'pending':
        return 'অপেক্ষমান';
      case 'rejected':
        return 'প্রত্যাখ্যানিত';
      default:
        return 'অনুমোদিত';
    }
  }

  // ডিটেইল আইটেম বিল্ডার
  Widget _buildDetailRow({
    required String label,
    required String value,
    IconData? icon,
    Color? color,
    bool isImportant = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Icon(icon, size: 20, color: color ?? Colors.grey),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isImportant ? 18 : 16,
                    color: color ?? Colors.black,
                    fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
                  ),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Image.network(
                imageUrl,
                fit: BoxFit.contain,
                height: 300,
              ),
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

  // সেকশন হেডার
  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // বিভিন্ন তারিখগুলো একসাথে রাখি
    final createdAt = _getDateTimeFromTimestamp(loanData['createdAt']);
    final approvedDate = _getDateTimeFromTimestamp(loanData['approvedDate']);
    final givenDate = _getDateTimeFromTimestamp(loanData['givenDate']);
    final paidDate = _getDateTimeFromTimestamp(loanData['paidDate']);
    final dueDate = _getDateTimeFromTimestamp(loanData['dueDate']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('লোনের বিস্তারিত'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditLoanScreen(
                    loanId: loanId,
                    loanData: loanData,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // হেডার কার্ড
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // প্রোফাইল এবং নাম
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 30,
                          child: Text(
                            loanData['name']
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loanData['name'] ?? 'নাম নেই',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                loanData['phone'] ?? 'নম্বর নেই',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    loanData['status'] ?? 'approved',
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getStatusColor(
                                      loanData['status'] ?? 'approved',
                                    ),
                                  ),
                                ),
                                child: Text(
                                  _getStatusText(
                                    loanData['status'] ?? 'approved',
                                  ),
                                  style: TextStyle(
                                    color: _getStatusColor(
                                      loanData['status'] ?? 'approved',
                                    ),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // লোন আইডি
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.receipt, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'লোন আইডি: $loanId',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // আর্থিক তথ্য
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      title: 'আর্থিক তথ্য',
                      icon: Icons.monetization_on,
                      color: Colors.green,
                    ),

                    _buildDetailRow(
                      label: 'আবেদনকৃত পরিমাণ',
                      value: '${loanData['amount']?.toString() ?? '0'} টাকা',
                      icon: Icons.request_page,
                      color: Colors.blue,
                      isImportant: true,
                    ),

                    if (loanData['approvedAmount'] != null)
                      _buildDetailRow(
                        label: 'অনুমোদিত পরিমাণ',
                        value: '${loanData['approvedAmount']} টাকা',
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),

                    if (loanData['interestRate'] != null)
                      _buildDetailRow(
                        label: 'সুদ হার',
                        value: '${loanData['interestRate']}%',
                        icon: Icons.percent,
                        color: Colors.orange,
                      ),

                    if (loanData['installmentAmount'] != null)
                      _buildDetailRow(
                        label: 'মাসিক কিস্তি',
                        value: '${loanData['installmentAmount']} টাকা',
                        icon: Icons.payments,
                        color: Colors.purple,
                      ),

                    if (loanData['totalPayable'] != null)
                      _buildDetailRow(
                        label: 'মোট পরিশোধযোগ্য',
                        value: '${loanData['totalPayable']} টাকা',
                        icon: Icons.calculate,
                        color: Colors.red,
                      ),

                    if (loanData['paidAmount'] != null)
                      _buildDetailRow(
                        label: 'পরিশোধিত পরিমাণ',
                        value: '${loanData['paidAmount']} টাকা',
                        icon: Icons.done_all,
                        color: Colors.blue,
                      ),

                    if (loanData['dueAmount'] != null)
                      _buildDetailRow(
                        label: 'বাকি পরিমাণ',
                        value: '${loanData['dueAmount']} টাকা',
                        icon: Icons.money_off,
                        color: Colors.red,
                      ),

                    if (loanData['purpose'] != null)
                      _buildDetailRow(
                        label: 'করজের উদ্দেশ্য',
                        value: loanData['purpose'],
                        icon: Icons.description,
                        color: Colors.brown,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ব্যক্তিগত তথ্য
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      title: 'ব্যক্তিগত তথ্য',
                      icon: Icons.person,
                      color: Colors.blue,
                    ),

                    _buildDetailRow(
                      label: 'ফোন নম্বর',
                      value: loanData['phone'] ?? 'নেই',
                      icon: Icons.phone,
                      color: Colors.blue,
                    ),

                    if (loanData['email'] != null)
                      _buildDetailRow(
                        label: 'ইমেইল',
                        value: loanData['email'],
                        icon: Icons.email,
                        color: Colors.blue,
                      ),

                    if (loanData['voterIdNumber'] != null)
                      _buildDetailRow(
                        label: 'ভোটার আইডি নম্বর',
                        value: loanData['voterIdNumber'],
                        icon: Icons.badge,
                        color: Colors.orange,
                      ),

                    if (loanData['nidNumber'] != null)
                      _buildDetailRow(
                        label: 'জাতীয় পরিচয়পত্র নম্বর',
                        value: loanData['nidNumber'],
                        icon: Icons.credit_card,
                        color: Colors.orange,
                      ),

                    if (loanData['bKashNumber'] != null)
                      _buildDetailRow(
                        label: 'বিকাশ নম্বর',
                        value: loanData['bKashNumber'],
                        icon: Icons.mobile_friendly,
                        color: Colors.purple,
                      ),

                    if (loanData['address'] != null)
                      _buildDetailRow(
                        label: 'ঠিকানা',
                        value: loanData['address'],
                        icon: Icons.location_on,
                        color: Colors.green,
                      ),

                    if (loanData['referenceNumber'] != null)
                      _buildDetailRow(
                        label: 'রেফারেন্স নম্বর',
                        value: loanData['referenceNumber'],
                        icon: Icons.confirmation_number,
                        color: Colors.indigo,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // তারিখ এবং সময়
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      title: 'তারিখসমূহ',
                      icon: Icons.calendar_today,
                      color: Colors.purple,
                    ),

                    if (createdAt != null)
                      _buildDetailRow(
                        label: 'আবেদনের তারিখ',
                        value: _formatDateTime(createdAt),
                        icon: Icons.date_range,
                        color: Colors.purple,
                      ),

                    if (approvedDate != null)
                      _buildDetailRow(
                        label: 'অনুমোদনের তারিখ',
                        value: _formatDateTime(approvedDate),
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),

                    if (givenDate != null)
                      _buildDetailRow(
                        label: 'করজ দেওয়ার তারিখ',
                        value: _formatDateTime(givenDate),
                        icon: Icons.attach_money,
                        color: Colors.purple,
                      ),

                    if (paidDate != null)
                      _buildDetailRow(
                        label: 'পরিশোধের তারিখ',
                        value: _formatDateTime(paidDate),
                        icon: Icons.done_all,
                        color: Colors.blue,
                      ),

                    if (dueDate != null)
                      _buildDetailRow(
                        label: 'পরিশোধের নির্ধারিত তারিখ',
                        value: _formatDate(dueDate),
                        icon: Icons.event,
                        color: Colors.orange,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // অতিরিক্ত তথ্য
            if (loanData['notes'] != null && loanData['notes'].toString().isNotEmpty)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        title: 'অতিরিক্ত তথ্য',
                        icon: Icons.note,
                        color: Colors.brown,
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.brown[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          loanData['notes'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ভোটার আইডি ছবি
            if (loanData['voterIdUrl'] != null && loanData['voterIdUrl'].toString().isNotEmpty)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        title: 'ভোটার আইডি ছবি',
                        icon: Icons.image,
                        color: Colors.orange,
                      ),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _showImageDialog(context, loanData['voterIdUrl']),
                          icon: const Icon(Icons.image),
                          label: const Text('ছবি দেখুন'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 30),

            // অ্যাকশন বাটন
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('ফিরে যান'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditLoanScreen(
                            loanId: loanId,
                            loanData: loanData,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('এডিট করুন'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}