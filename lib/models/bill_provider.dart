import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 1. MODEL DATA BILL (DENGAN FUNGSI TO MAP & FROM MAP)
class BillModel {
  final String id;
  final String name;
  final String amount;
  final String category;
  final String dueDate;
  final String status;
  final int? notificationId;

  BillModel({
    String? id,
    required this.name,
    required this.amount,
    required this.category,
    required this.dueDate,
    this.status = 'Unpaid Bill',
    this.notificationId,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Konversi dari Firebase (Map) ke Object
  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      category: map['category'],
      dueDate: map['dueDate'],
      status: map['status'],
      notificationId: map['notificationId'],
    );
  }

  // Konversi dari Object ke Map (Untuk simpan ke Firebase)
  Map<String, dynamic> toMap() {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'dueDate': dueDate,
      'status': status,
      'notificationId': notificationId,
      'userId': uid, // Filter agar data per user
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

// 2. BILL PROVIDER DENGAN CLOUD FIRESTORE
class BillProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<BillModel> _allBills = [];

  List<BillModel> get allBills => _allBills;

  // --- AMBIL DATA DARI FIREBASE ---
  Future<void> fetchBills() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await _firestore
          .collection('bills')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      _allBills = snapshot.docs
          .map((doc) => BillModel.fromMap(doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      print("Error fetching bills: $e");
    }
  }

  // --- TAMBAH BILL KE FIREBASE ---
  Future<void> addBill(BillModel bill) async {
    try {
      await _firestore.collection('bills').doc(bill.id).set(bill.toMap());
      _allBills.insert(0, bill); // Tambah di paling atas list local
      notifyListeners();
    } catch (e) {
      print("Error adding bill: $e");
    }
  }

  // --- UPDATE STATUS BAYAR KE FIREBASE ---
  Future<void> markBillAsPaid(BillModel bill) async {
    try {
      await _firestore.collection('bills').doc(bill.id).update({
        'status': 'Paid',
      });

      final index = _allBills.indexWhere((b) => b.id == bill.id);
      if (index != -1) {
        // Update local list
        _allBills[index] = BillModel(
          id: bill.id,
          name: bill.name,
          amount: bill.amount,
          category: bill.category,
          dueDate: bill.dueDate,
          status: 'Paid',
          notificationId: bill.notificationId,
        );
        notifyListeners();
      }
    } catch (e) {
      print("Error updating bill: $e");
    }
  }

  // --- HAPUS BILL DARI FIREBASE ---
  Future<void> deleteBill(String billId) async {
    try {
      await _firestore.collection('bills').doc(billId).delete();
      _allBills.removeWhere((bill) => bill.id == billId);
      notifyListeners();
    } catch (e) {
      print("Error deleting bill: $e");
    }
  }
}
