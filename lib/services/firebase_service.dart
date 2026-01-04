import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/loan_model.dart';
import '../models/donation_model.dart';
import '../models/user_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // User Methods
  static Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').add(user.toMap());
  }

  static Future<UserModel?> getUserByPhone(String phone) async {
    final query = await _firestore
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) {
      return UserModel.fromMap(query.docs.first.data());
    }
    return null;
  }

  // Loan Methods
  static Future<String> createLoan(LoanModel loan) async {
    final docRef = await _firestore.collection('loans').add(loan.toMap());
    return docRef.id;
  }

  static Stream<QuerySnapshot> getLoansStream() {
    return _firestore
        .collection('loans')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getLoansByPhone(String phone) {
    return _firestore
        .collection('loans')
        .where('phone', isEqualTo: phone)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getLoansByStatus(String status) {
    return _firestore
        .collection('loans')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> updateLoanStatus(String loanId, String status) async {
    await _firestore.collection('loans').doc(loanId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteLoan(String loanId, String? imageUrl) async {
    // Delete image from storage if exists
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        await _storage.refFromURL(imageUrl).delete();
      } catch (e) {
        print('Error deleting image: $e');
      }
    }
    
    // Delete loan document
    await _firestore.collection('loans').doc(loanId).delete();
  }

  // Donation Methods
  static Future<void> addDonation(DonationModel donation) async {
    await _firestore.collection('donations').add({
      'name': donation.name,
      'phone': donation.phone,
      'amount': donation.amount,
      'date': donation.date,
      'voterIdUrl': donation.voterIdUrl,
      'createdAt': donation.createdAt,
    });
  }

  // Image Upload
  static Future<String> uploadImage(File image, String fileName) async {
    try {
      final ref = _storage.ref().child('voter_ids/$fileName');
      final uploadTask = ref.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  // Get all loans (for admin)
  static Stream<List<LoanModel>> getAllLoans() {
    return _firestore
        .collection('loans')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LoanModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}