import 'package:cloud_firestore/cloud_firestore.dart';

class DonationModel {
  final String name;
  final String phone;
  final String address;
  final String voterIdUrl;
  final DateTime date;
  final int amount;
  final DateTime createdAt;

  DonationModel({
    required this.name,
    required this.phone,
    required this.address,
    required this.voterIdUrl,
    required this.date,
    required this.amount,
    required this.createdAt,
  });
  // Model → Map (Firebase upload)
  factory DonationModel.fromMap(Map<String, dynamic> map) {
    return DonationModel(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      voterIdUrl: map['voterIdUrl'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      amount: map['amount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
