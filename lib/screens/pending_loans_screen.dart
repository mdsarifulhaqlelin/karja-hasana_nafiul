import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:karja_hasana/screens/admin_loan_review_screen.dart';
import 'package:karja_hasana/screens/edit_loan_screen.dart';

class PendingLoansScreen extends StatefulWidget {
  const PendingLoansScreen({super.key});

  @override
  State<PendingLoansScreen> createState() => _PendingLoansScreenState();
}

class _PendingLoansScreenState extends State<PendingLoansScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

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
    super.dispose();
  }

  // ✅ Loan Review Screen-এ নেভিগেট করার function
  void _navigateToReviewScreen(BuildContext context, String loanId, Map<String, dynamic> loanData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminLoanReviewScreen(
          loanId: loanId,
          loanData: loanData,
        ),
      ),
    );
  }

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
                  fontWeight: FontWeight.bold,
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

  // লোন ডিলিট
  Future<void> _deleteLoan(String loanId, String? imageUrl) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🗑️ নিশ্চিত করুন'),
        content: const Text('আপনি কি এই লোন আবেদনটি ডিলিট করতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('না'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('হ্যাঁ, ডিলিট করুন'),
          ),
        ],
      ),
    );

    if (!confirm) return;

    setState(() => _isLoading = true);

    try {
      // ছবি ডিলিট
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final storageRef = _storage.refFromURL(imageUrl);
          await storageRef.delete();
        } catch (e) {
          debugPrint('⚠️ ছবি ডিলিটে সমস্যা: $e');
        }
      }

      // ফায়ারস্টোর থেকে ডিলিট
      await _firestore.collection('loans').doc(loanId).delete();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ ডিলিট করা হয়েছে'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ডিলিট ব্যর্থ: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // লোন এডিট
  void _editLoan(String loanId, Map<String, dynamic> loanData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditLoanScreen(
          loanId: loanId,
          loanData: loanData,
        ),
      ),
    );
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
      final lowercaseQuery = query.toLowerCase();

      return name.contains(lowercaseQuery) ||
             phone.contains(lowercaseQuery) ||
             voterId.contains(lowercaseQuery);
    }).toList();
  }

  // খালি স্ক্রিন উইজেট
  Widget _buildEmptyScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green.shade300,
          ),
          const SizedBox(height: 20),
          const Text(
            '🎉 কোন অপেক্ষমান আবেদন নেই!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'সকল আবেদন প্রক্রিয়াকরণ সম্পন্ন হয়েছে।',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.home),
            label: const Text('হোমে ফিরে যান'),
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
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              _searchController.clear();
              FocusScope.of(context).unfocus();
            },
            child: const Text('সকল আবেদন দেখুন'),
          ),
        ],
      ),
    );
  }

  // ✅ Clickable Loan Card Widget
  Widget _buildLoanCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final loanId = doc.id;

    return GestureDetector(
      onTap: () {
        // কার্ডে ক্লিক করলে Loan Review Screen এ নিয়ে যাবে
        _navigateToReviewScreen(context, loanId, data);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: 3,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.orange.shade200, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
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
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Text(
                      'রিভিউ প্রয়োজন',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ✅ Quick Info Section (ক্লিক করলে details দেখবে)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // টাকার পরিমাণ
                    Row(
                      children: [
                        const Icon(Icons.money, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          '${data['amount']?.toString() ?? '0'} টাকা',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // ভোটার আইডি (যদি থাকে)
                    if (data['voterIdNumber'] != null && data['voterIdNumber'].toString().isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.badge, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'ভোটার আইডি: ${data['voterIdNumber']}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    
                    // ✅ ক্লিক করার নির্দেশিকা
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.info, size: 14, color: Colors.blue),
                          const SizedBox(width: 4),
                          const Text(
                            'বিস্তারিত দেখে সিদ্ধান্ত নিতে ট্যাপ করুন',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              
              // অতিরিক্ত অপশন
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
                  
                  // Quick Actions Menu
                  PopupMenuButton<String>(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit, color: Colors.blue),
                          title: Text('এডিট করুন'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('ডিলিট করুন'),
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'delete') {
                        await _deleteLoan(loanId, data['voterIdUrl']);
                      } else if (value == 'edit') {
                        _editLoan(loanId, data);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.more_horiz, color: Colors.grey),
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
        title: const Text('নতুন লোন আবেদন'),
        backgroundColor: Colors.orange,
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
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.orange.shade50,
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'লোনে ট্যাপ করে বিস্তারিত দেখে সিদ্ধান্ত নিন',
                    style: TextStyle(fontSize: 14, color: Colors.orange),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('loans')
                      .where('status', isEqualTo: 'pending')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$count টি নতুন',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // লিস্ট ভিউ
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('loans')
                  .where('status', isEqualTo: 'pending')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // ত্রুটি হ্যান্ডলিং
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '❌ ত্রুটি: ${snapshot.error}',
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