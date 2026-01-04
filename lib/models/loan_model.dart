import 'package:cloud_firestore/cloud_firestore.dart';

class LoanModel {
  final String? id; // Document ID
  final String name;
  final String address;
  final String phone;
  final String referenceNumber;
  final String bKashNumber;
  final String voterIdNumber;
  final int amount;
  final String voterIdUrl;
  final DateTime dueDate;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LoanModel({
    this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.referenceNumber,
    required this.bKashNumber,
    required this.voterIdNumber,
    required this.amount,
    required this.voterIdUrl,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  // Model → Map (Firebase upload)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'referenceNumber': referenceNumber,
      'bKashNumber': bKashNumber,
      'voterIdNumber': voterIdNumber,
      'amount': amount,
      'voterIdUrl': voterIdUrl,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Map → Model (Firebase থেকে পড়া)
  factory LoanModel.fromMap(Map<String, dynamic> map, String id) {
    return LoanModel(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      referenceNumber: map['referenceNumber'] ?? '',
      bKashNumber: map['bKashNumber'] ?? '',
      voterIdNumber: map['voterIdNumber'] ?? '',
      amount: map['amount'] ?? 0,
      voterIdUrl: map['voterIdUrl'] ?? '', // Correct field name
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}