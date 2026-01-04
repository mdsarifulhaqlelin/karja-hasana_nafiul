import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String phone;
  final String voterId;
  final DateTime createdAt;

  UserModel({
    required this.phone,
    required this.voterId,
    required this.createdAt,
  });
  // Model → Map (Firebase upload)
  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'voterId': voterId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Map → Model (Firebase থেকে পড়া)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      phone: map['phone'] ?? '',
      voterId: map['voterId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
