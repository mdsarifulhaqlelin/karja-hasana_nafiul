import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:karja_hasana/screens/edit_loan_screen.dart';

class LoanListScreen extends StatefulWidget {
  const LoanListScreen({super.key});

  @override
  State<LoanListScreen> createState() => _LoanListScreenState();
}

class _LoanListScreenState extends State<LoanListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedFilter = 'all';
  // ignore: unused_field
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

  // ✅ অবশ্যই এখানে ডিক্লেয়ার করুন - ক্লাস লেভেলে
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('কর্জ আবেদন তালিকা'),
        backgroundColor: Colors.blue,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _selectedFilter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('সব আবেদন')),
              const PopupMenuItem(value: 'pending', child: Text('অপেক্ষমান')),
              const PopupMenuItem(value: 'approved', child: Text('অনুমোদিত')),
              const PopupMenuItem(
                value: 'rejected',
                child: Text('প্রত্যাখ্যাত'),
              ),
              const PopupMenuItem(value: 'paid', child: Text('পরিশোধিত')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.0),
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
                          hintText:
                              'নাম, ফোন, রেফারেন্স বা ভোটার আইডি সার্চ করুন...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey[600]),
                        ),
                        style: const TextStyle(fontSize: 14),
                        onSubmitted: (_) {
                          // সার্চ এন্টার প্রেস করলে কী-বোর্ড হাইড করবে
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
          // সার্চ রেজাল্ট কাউন্টার (ঐচ্ছিক)
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'সার্চ রেজাল্ট: "$_searchQuery"',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      FocusScope.of(context).unfocus();
                    },
                    child: const Text(
                      'সার্চ ক্লিয়ার করুন',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('❌ ত্রুটি: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'কোন আবেদন পাওয়া যায়নি',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                // সার্চ ফিল্টার এপ্লাই করুন
                List<QueryDocumentSnapshot> filteredDocs = snapshot.data!.docs;

                if (_searchQuery.isNotEmpty) {
                  filteredDocs = filteredDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name']?.toString().toLowerCase() ?? '';
                    final phone = data['phone']?.toString().toLowerCase() ?? '';
                    final reference =
                        data['referenceNumber']?.toString().toLowerCase() ?? '';
                    final bKash =
                        data['bKashNumber']?.toString().toLowerCase() ?? '';
                    final voterId =
                        data['voterIdNumber']?.toString().toLowerCase() ?? '';
                    final amount = data['amount']?.toString() ?? '';
                    final query = _searchQuery.toLowerCase();

                    return name.contains(query) ||
                        phone.contains(query) ||
                        reference.contains(query) ||
                        bKash.contains(query) ||
                        voterId.contains(query) ||
                        amount.contains(query);
                  }).toList();
                }

                if (filteredDocs.isEmpty) {
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

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final dueDate = (data['dueDate'] as Timestamp).toDate();
                    final createdAt = (data['createdAt'] as Timestamp).toDate();

                    Color statusColor = Colors.orange;
                    String statusText = 'অপেক্ষমান';

                    if (data['status'] == 'approved') {
                      statusColor = Colors.green;
                      statusText = 'অনুমোদিত';
                    } else if (data['status'] == 'rejected') {
                      statusColor = Colors.red;
                      statusText = 'প্রত্যাখ্যাত';
                    } else if (data['status'] == 'paid') {
                      statusColor = Colors.blue;
                      statusText = 'পরিশোধিত';
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    data['name'] ?? 'নাম নেই',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: statusColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: statusColor),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  data['phone'] ?? 'নম্বর নেই',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.money,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 6),
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
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'আবেদনের তারিখ: ${_formatDateTime(createdAt)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.date_range,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'পরিশোধের তারিখ: ${_formatDate(dueDate)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            Row(
                              children: [
                                const Icon(
                                  Icons.format_list_numbered,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'বিকাশ নম্বর: ${data['bKashNumber']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            if (data['bKashNumber'] != null && data['bKashNumber'].toString().isNotEmpty)
                            Padding(padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.attach_money,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'বিকাশ: ${data['bKashNumber']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // রেফারেন্স
                            if (data['referenceNumber'] != null &&
                                data['referenceNumber'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.tag,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'রেফারেন্স: ${data['referenceNumber']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // ভোটার আইডি
                            if (data['voterIdNumber'] != null &&
                                data['voterIdNumber'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.badge,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'ভোটার আইডি: ${data['voterIdNumber']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (data['voterIdUrl'] != null &&
                                    data['voterIdUrl'].toString().isNotEmpty)
                                  ElevatedButton.icon(
                                    onPressed: () => _showImageDialog(
                                      context,
                                      data['voterIdUrl'],
                                    ),
                                    icon: const Icon(Icons.image, size: 16),
                                    label: const Text('ছবি দেখুন'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                    ),
                                  ),

                                const SizedBox(width: 8),

                                PopupMenuButton<String>(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'approved',
                                      child: Text('✅ অনুমোদন করুন'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'rejected',
                                      child: Text('❌ প্রত্যাখ্যান করুন'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'paid',
                                      child: Text('💰 পরিশোধিত চিহ্নিত করুন'),
                                    ),
                                    const PopupMenuDivider(),
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        title: Text('এডিট করুন'),
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        title: Text('ডিলিট করুন'),
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) async {
                                    if (value == 'delete') {
                                      await _deleteLoan(
                                        doc.id,
                                        data['voterIdUrl'],
                                      ); // টাইপো ফিক্সড
                                    } else if (value == 'edit') {
                                      _editLoan(doc.id, data); // ঠিক করা হয়েছে
                                    } else {
                                      await _updateStatus(doc.id, value);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.more_vert,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'অপশন',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
  String _formatDateTime(DateTime date) {
    return DateFormat('d/M/yyyy h:mm a').format(date);
  }

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
              Image.network(imageUrl, fit: BoxFit.contain, height: 200),
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

  // স্ট্যাটাস আপডেট মেথড
  Future<void> _updateStatus(String docId, String status) async {
    try {
      await _firestore.collection('loans').doc(docId).update({
        'status': status,
        'updatedAt': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ স্ট্যাটাস আপডেট হয়েছে'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ আপডেট ব্যর্থ: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // ডিলেট ফাংশন (Firebase থেকে সম্পূর্ণ মুছে ফেলা)
  // _deleteLoan মেথড
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
      // Storage থেকে ছবি মুছুন
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
          await storageRef.delete();
        } catch (e) {
          print('⚠️ ছবি ডিলিটে সমস্যা: $e');
        }
      }

      // Firestore থেকে ডকুমেন্ট মুছুন
      await _firestore.collection('loans').doc(loanId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ ডিলিট করা হয়েছে'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ডিলিট ব্যর্থ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // এডিট ফাংশন (EditLoanScreen এ নেভিগেট) - ভুল সংশোধন করা হয়েছে
  void _editLoan(String loanId, Map<String, dynamic> loanData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditLoanScreen(
          loanId: loanId, // ঠিক আছে
          loanData: loanData, // ঠিক আছে
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredStream() {
    if (_selectedFilter == 'all') {
      return _firestore
          .collection('loans')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      return _firestore
          .collection('loans')
          .where('status', isEqualTo: _selectedFilter)
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }
}
