import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'package:karja_hasana/screens/loan_details_screen.dart';

class GivenLoansScreen extends StatefulWidget {
  const GivenLoansScreen({super.key});

  @override
  State<GivenLoansScreen> createState() => _GivenLoansScreenState();
}

class _GivenLoansScreenState extends State<GivenLoansScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // ignore: unused_field
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  // করজ দেওয়ার জন্য কন্ট্রোলার
  final TextEditingController _approvedAmountController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _installmentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _approvedAmountController.dispose();
    _interestRateController.dispose();
    _installmentController.dispose();
    super.dispose();
  }

  // ফর্ম্যাটেড ডেট টাইম
  // String _formatDateTime(DateTime? date) {
  //   if (date == null) return 'তারিখ নেই';
  //   return DateFormat('d/M/yyyy h:mm a').format(date);
  // }

  // ফর্ম্যাটেড তারিখ
  // String _formatDate(DateTime? date) {
  //   if (date == null) return 'তারিখ নেই';
  //   return DateFormat('d/M/yyyy').format(date);
  // }

  // ছবি দেখানোর ডায়ালোগ
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
                  fontWeight: .bold,
                ),
              ),
              const SizedBox(height: 10),
              Image.network(
                imageUrl,
                fit: BoxFit.contain,
                height: 200,
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

  // করজ দেওয়ার ডায়ালোগ
  // void _showGiveLoanDialog(String loanId, Map<String, dynamic> loanData) {
  //   // ডিফল্ট ভ্যালু সেট করুন
  //   _approvedAmountController.text = loanData['amount']?.toString() ?? '';
  //   _interestRateController.text = '5'; // ডিফল্ট সুদ হার
  //   _installmentController.text = '';

  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('কর্জ দিন'),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextFormField(
  //               controller: _approvedAmountController,
  //               decoration: const InputDecoration(
  //                 labelText: 'কর্জের পরিমাণ (টাকা)',
  //                 border: OutlineInputBorder(),
  //               ),
  //               keyboardType: TextInputType.number,
  //             ),
  //             const SizedBox(height: 12),
  //             TextFormField(
  //               controller: _interestRateController,
  //               decoration: const InputDecoration(
  //                 labelText: 'সুদ হার (%)',
  //                 border: OutlineInputBorder(),
  //               ),
  //               keyboardType: TextInputType.number,
  //             ),
  //             const SizedBox(height: 12),
  //             TextFormField(
  //               controller: _installmentController,
  //               decoration: const InputDecoration(
  //                 labelText: 'মাসিক কিস্তি (টাকা)',
  //                 border: OutlineInputBorder(),
  //                 hintText: 'ঐচ্ছিক',
  //               ),
  //               keyboardType: TextInputType.number,
  //             ),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('বাতিল'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () => _giveLoan(loanId, loanData),
  //           child: const Text('কর্জ দিন'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // করজ দেওয়ার ফাংশন
  // Future<void> _giveLoan(String loanId, Map<String, dynamic> loanData) async {
  //   try {
  //     double approvedAmount = double.tryParse(_approvedAmountController.text) ?? 0;
  //     double interestRate = double.tryParse(_interestRateController.text) ?? 0;
  //     double installmentAmount = double.tryParse(_installmentController.text) ?? 0;

  //     await _firestore.collection('loans').doc(loanId).update({
  //       'status': 'given',
  //       'approvedAmount': approvedAmount,
  //       'interestRate': interestRate,
  //       'installmentAmount': installmentAmount > 0 ? installmentAmount : null,
  //       'givenDate': Timestamp.now(),
  //       'updatedAt': Timestamp.now(),
  //     });

  //     Navigator.pop(context);
      
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('✅ করজ সফলভাবে দেওয়া হয়েছে'),
  //         backgroundColor: Colors.green,
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('❌ ত্রুটি: $e'),
  //         backgroundColor: Colors.red,
  //         duration: const Duration(seconds: 2),
  //       ),
  //     );
  //   }
  // }

  // স্ট্যাটাস আপডেট (পরিশোধিত)
  Future<void> _updateStatus(String docId, String status) async {
    try {
      await _firestore.collection('loans').doc(docId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ স্ট্যাটাস আপডেট হয়েছে: ${status == 'paid' ? 'পরিশোধিত' : status}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ আপডেট ব্যর্থ: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // হেল্পার ফাংশন: স্ট্যাটাস কালার
  // ignore: unused_element
  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'given':
        return Colors.purple;
      case 'paid':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  // হেল্পার ফাংশন: স্ট্যাটাস আইকন
  // ignore: unused_element
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'given':
        return Icons.attach_money;
      case 'paid':
        return Icons.done_all;
      default:
        return Icons.check_circle;
    }
  }

  // হেল্পার ফাংশন: স্ট্যাটাস টেক্সট
  // ignore: unused_element
  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'অনুমোদিত';
      case 'given':
        return 'কর্জ দেওয়া হয়েছে';
      case 'paid':
        return 'পরিশোধিত';
      default:
        return 'অনুমোদিত';
    }
  }

  // ফিল্টার করা লিস্ট
  List<QueryDocumentSnapshot> _filterDocuments(
    List<QueryDocumentSnapshot> allDocs,
    String query
  ) {
    if (query.isEmpty) return allDocs;

    return allDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final name = data['name']?.toString().toLowerCase() ?? '';
      final phone = data['phone']?.toString().toLowerCase() ?? '';
      final voterId = data['voterIdNumber']?.toString().toLowerCase() ?? '';
      final reference = data['referenceNumber']?.toString().toLowerCase() ?? '';
      final lowercaseQuery = query.toLowerCase();

      return name.contains(lowercaseQuery) ||
             phone.contains(lowercaseQuery) ||
             voterId.contains(lowercaseQuery) ||
             reference.contains(lowercaseQuery);
    }).toList();
  }

  // খালি স্ক্রিন উইজেট
  Widget _buildEmptyScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.money_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          const Text(
            'কোন অনুমোদিত করজ নেই',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '"কর্জ দিতে হবে" থেকে প্রথমে কিছু আবেদন অনুমোদন করুন।',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // সার্চ খালি স্ক্রিন উইজেট
  Widget _buildSearchEmptyScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '"$_searchQuery" এর সাথে মিলে এমন কোন আবেদন নেই',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // লোন কার্ড উইজেট
  Widget _buildLoanCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    // final approvedDate = (data['approvedDate'] as Timestamp?)?.toDate();
    // final givenDate = (data['givenDate'] as Timestamp?)?.toDate();
    // final dueDate = (data['dueDate'] as Timestamp?)?.toDate();
    final loanId = doc.id;

    // স্ট্যাটাস কালার এবং টেক্সট
    Color statusColor = Colors.green;
    String statusText = 'অনুমোদিত';
    IconData statusIcon = Icons.check_circle;

    if (data['status'] == 'given') {
      statusColor = Colors.purple;
      statusText = 'কর্জ দেওয়া হয়েছে';
      statusIcon = Icons.attach_money;
    } else if (data['status'] == 'paid') {
      statusColor = Colors.blue;
      statusText = 'পরিশোধিত';
      statusIcon = Icons.done_all;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: statusColor.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoanDetailsScreen(
                loanData: data,
                loanId: loanId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // হেডার
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name'] ?? 'নাম নেই',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['phone'] ?? 'নম্বর নেই',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              
              // টাকার পরিমাণ
              // Row(
              //   children: [
              //     const Icon(Icons.money, size: 16, color: Colors.green),
              //     const SizedBox(width: 6),
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           'আবেদনকৃত: ${data['amount']?.toString() ?? '0'} টাকা',
              //           style: const TextStyle(
              //             fontWeight: FontWeight.bold,
              //             color: Colors.green,
              //             fontSize: 16,
              //           ),
              //         ),
              //         if (data['approvedAmount'] != null && data['status'] == 'given')
              //           Text(
              //             'অনুমোদিত: ${data['approvedAmount']?.toString() ?? '0'} টাকা',
              //             style: const TextStyle(
              //               fontWeight: FontWeight.bold,
              //               color: Colors.purple,
              //               fontSize: 14,
              //             ),
              //           ),
              //       ],
              //     ),
              //   ],
              // ),

              // করজের বিবরণ (যদি দেওয়া হয়ে থাকে)
              if (data['status'] == 'given')
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'কর্জের বিবরণ:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      // const SizedBox(height: 4),
                      // if (data['interestRate'] != null)
                      //   Text(
                      //     '• সুদ হার: ${data['interestRate']}%',
                      //     style: const TextStyle(fontSize: 12),
                      //   ),
                      // if (data['installmentAmount'] != null)
                      //   Text(
                      //     '• মাসিক কিস্তি: ${data['installmentAmount']} টাকা',
                      //     style: const TextStyle(fontSize: 12),
                      //   ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),
              
              // তারিখসমূহ
              // if (createdAt != null)
              //   Row(
              //     children: [
              //       const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              //       const SizedBox(width: 6),
              //       Text(
              //         'আবেদনের তারিখ: ${_formatDateTime(createdAt)}',
              //         style: const TextStyle(fontSize: 12, color: Colors.grey),
              //       ),
              //     ],
              //   ),

              // if (approvedDate != null)
              //   Padding(
              //     padding: const EdgeInsets.only(top: 4),
              //     child: Row(
              //       children: [
              //         const Icon(Icons.check_circle, size: 16, color: Colors.green),
              //         const SizedBox(width: 6),
              //         Text(
              //           'অনুমোদনের তারিখ: ${_formatDateTime(approvedDate)}',
              //           style: const TextStyle(fontSize: 12, color: Colors.grey),
              //         ),
              //       ],
              //     ),
              //   ),

              // if (givenDate != null)
              //   Padding(
              //     padding: const EdgeInsets.only(top: 4),
              //     child: Row(
              //       children: [
              //         const Icon(Icons.attach_money, size: 16, color: Colors.purple),
              //         const SizedBox(width: 6),
              //         Text(
              //           'কর্জ দেওয়ার তারিখ: ${_formatDateTime(givenDate)}',
              //           style: const TextStyle(fontSize: 12, color: Colors.grey),
              //         ),
              //       ],
              //     ),
              //   ),

              // if (dueDate != null)
              //   Padding(
              //     padding: const EdgeInsets.only(top: 4),
              //     child: Row(
              //       children: [
              //         const Icon(Icons.date_range, size: 16, color: Colors.grey),
              //         const SizedBox(width: 6),
              //         Text(
              //           'পরিশোধের তারিখ: ${_formatDate(dueDate)}',
              //           style: const TextStyle(fontSize: 12, color: Colors.grey),
              //         ),
              //       ],
              //     ),
              //   ),

              // ভোটার আইডি
              // if (data['voterIdNumber'] != null && data['voterIdNumber'].toString().isNotEmpty)
              //   Padding(
              //     padding: const EdgeInsets.only(top: 4),
              //     child: Row(
              //       children: [
              //         const Icon(Icons.badge, size: 16, color: Colors.grey),
              //         const SizedBox(width: 6),
              //         Text(
              //           'ভোটার আইডি: ${data['voterIdNumber']}',
              //           style: const TextStyle(fontSize: 12, color: Colors.grey),
              //         ),
              //       ],
              //     ),
              //   ),

              const SizedBox(height: 12),
              
              // অ্যাকশন বাটন
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (data['voterIdUrl'] != null && data['voterIdUrl'].toString().isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _showImageDialog(context, data['voterIdUrl']),
                      icon: const Icon(Icons.image, size: 16),
                      label: const Text('ছবি দেখুন'),
                    ),
                  
                  const Spacer(),
                  
                  // করজ দিন বাটন (শুধুমাত্র approved অবস্থায়)
                  // if (data['status'] == 'approved')
                  //   ElevatedButton.icon(
                  //     onPressed: () => _showGiveLoanDialog(loanId, data),
                  //     icon: const Icon(Icons.attach_money, size: 16),
                  //     label: const Text('কর্জ দিন'),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.purple,
                  //       foregroundColor: Colors.white,
                  //     ),
                  //   ),
                  
                  // পরিশোধিত বাটন (শুধুমাত্র given অবস্থায়)
                  if (data['status'] == 'given')
                    ElevatedButton.icon(
                      onPressed: () => _updateStatus(loanId, 'paid'),
                      icon: const Icon(Icons.done_all, size: 16),
                      label: const Text('পরিশোধিত'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
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
        title: const Text('কর্জ দেওয়া হয়েছে'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'রিফ্রেশ করুন',
          ),
        ],
      ),
      body: Column(
        children: [
          // সার্চ বার
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'নাম, ফোন বা ভোটার আইডি দিয়ে খুঁজুন...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey[600]),
                        ),
                        style: const TextStyle(fontSize: 14),
                        onSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // স্ট্যাটাস বার
          // Container(
          //   padding: const EdgeInsets.all(12),
          //   color: Colors.green.shade50,
          //   child: Row(
          //     children: [
          //       const Icon(Icons.info, color: Colors.green, size: 20),
          //       const SizedBox(width: 8),
          //       const Expanded(
          //         child: Text(
          //           'অনুমোদিত এবং করজ দেওয়া আবেদনগুলোর তালিকা। এখান থেকে করজের বিবরণ দিন বা স্ট্যাটাস আপডেট করুন।',
          //           style: TextStyle(fontSize: 12, color: Colors.green),
          //         ),
          //       ),
          //       Container(
          //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          //         decoration: BoxDecoration(
          //           color: Colors.green,
          //           borderRadius: BorderRadius.circular(20),
          //         ),
          //         child: StreamBuilder<QuerySnapshot>(
          //           stream: _firestore
          //               .collection('loans')
          //               .where('status', whereIn: ['approved', 'given', 'paid'])
          //               .snapshots(),
          //           builder: (context, snapshot) {
          //             final count = snapshot.data?.docs.length ?? 0;
          //             return Text(
          //               '$count টি',
          //               style: const TextStyle(
          //                 color: Colors.white,
          //                 fontWeight: FontWeight.bold,
          //                 fontSize: 12,
          //               ),
          //             );
          //           },
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          
          // লিস্ট ভিউ
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('loans')
                  .where('status', whereIn: ['approved', 'given', 'paid'])
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // ত্রুটি হ্যান্ডলিং
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'ত্রুটি: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                // লোডিং স্টেট
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // ডাটা না পাওয়া
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyScreen();
                }

                // ডাটা পাওয়া গেছে
                final allDocs = snapshot.data!.docs;
                final filteredDocs = _filterDocuments(allDocs, _searchQuery);

                // সার্চের পর খালি
                if (filteredDocs.isEmpty) {
                  return _buildSearchEmptyScreen();
                }

                // লিস্ট বিল্ড
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    return _buildLoanCard(filteredDocs[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}