import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditLoanScreen extends StatefulWidget {
  final String loanId;
  final Map<String, dynamic> loanData;

  const EditLoanScreen({
    super.key,
    required this.loanId,
    required this.loanData,
  });

  @override
  State<EditLoanScreen> createState() => _EditLoanScreenState();
}

class _EditLoanScreenState extends State<EditLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _amountController;
  late TextEditingController _referenceController;
  late TextEditingController _voterIdController;
  late DateTime _dueDate;
  late String _selectedStatus;
  bool _isLoading = false;

  final List<String> _statusOptions = ['pending', 'approved', 'rejected', 'paid'];
  final Map<String, String> _statusLabels = {
    'pending': 'অপেক্ষমান',
    'approved': 'অনুমোদিত',
    'rejected': 'প্রত্যাখ্যাত',
    'paid': 'পরিশোধিত',
  };

  @override
  void initState() {
    super.initState();
    // Firebase থেকে আসা ডেটা দিয়ে ফিল্ড প্রিফিল করা
    _nameController = TextEditingController(text: widget.loanData['name'] ?? '');
    _phoneController = TextEditingController(text: widget.loanData['phone'] ?? '');
    _addressController = TextEditingController(text: widget.loanData['address'] ?? '');
    _amountController = TextEditingController(text: widget.loanData['amount']?.toString() ?? '');
    _referenceController = TextEditingController(text: widget.loanData['referenceNumber'] ?? '');
    _voterIdController = TextEditingController(text: widget.loanData['voterIdNumber'] ?? '');
    _dueDate = (widget.loanData['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    _selectedStatus = widget.loanData['status'] ?? 'pending';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    _voterIdController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  // Firebase এ আপডেট করার মেথড
  Future<void> _updateLoan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'amount': double.parse(_amountController.text.trim()),
        'dueDate': Timestamp.fromDate(_dueDate),
        'status': _selectedStatus,
        'referenceNumber': _referenceController.text.trim(),
        'voterIdNumber': _voterIdController.text.trim(),
        'updatedAt': Timestamp.now(),
      };

      // Firebase Firestore এ আপডেট
      await FirebaseFirestore.instance
          .collection('loans')
          .doc(widget.loanId)
          .update(updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ আবেদন সফলভাবে আপডেট হয়েছে'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // পূর্ববর্তী স্ক্রিনে ফেরত
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ আপডেট ব্যর্থ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('আবেদন এডিট করুন'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'নাম *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value?.trim().isEmpty ?? true) ? 'নাম প্রয়োজন' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'ফোন নম্বর *',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) return 'ফোন নম্বর প্রয়োজন';
                  if (value!.trim().length < 11) return 'সঠিক নম্বর দিন';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'অর্থের পরিমাণ *',
                  prefixIcon: Icon(Icons.money),
                  border: OutlineInputBorder(),
                  suffixText: 'টাকা',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) return 'অর্থের পরিমাণ প্রয়োজন';
                  if (double.tryParse(value!.trim()) == null) return 'সঠিক অংক দিন';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'স্ট্যাটাস *',
                  prefixIcon: Icon(Icons.info),
                  border: OutlineInputBorder(),
                ),
                items: _statusOptions.map((status) => 
                  DropdownMenuItem(
                    value: status, 
                    child: Text(_statusLabels[status]!)
                  )
                ).toList(),
                onChanged: (value) => setState(() => _selectedStatus = value!),
                validator: (value) => value?.isEmpty ?? true ? 'স্ট্যাটাস নির্বাচন করুন' : null,
              ),
              const SizedBox(height: 16),
              
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'পরিশোধের তারিখ *',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text('${_dueDate.day}/${_dueDate.month}/${_dueDate.year}', style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'রেফারেন্স নম্বর (ঐচ্ছিক)',
                  prefixIcon: Icon(Icons.tag),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _voterIdController,
                decoration: const InputDecoration(
                  labelText: 'ভোটার আইডি নম্বর (ঐচ্ছিক)',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _updateLoan,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text(
                      'আপডেট করুন',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}