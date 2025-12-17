import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionProvider extends ChangeNotifier {
  // Database Reference
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Data Lokal
  List<Map<String, dynamic>> _transactions = [];
  int _balance = 0;
  int _totalExpense = 0;
  int _totalIncome = 0;

  // Getter
  List<Map<String, dynamic>> get transactions => _transactions;
  int get balance => _balance;
  int get totalExpense => _totalExpense;
  int get totalIncome => _totalIncome;

  TransactionProvider() {
    _listenToTransactions();
  }

  // 1. LISTEN DATA DARI FIREBASE
  void _listenToTransactions() {
    User? user = _auth.currentUser;
    if (user == null) return;

    _db
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _transactions = [];
          _balance = 0;
          _totalIncome = 0;
          _totalExpense = 0;

          for (var doc in snapshot.docs) {
            Map<String, dynamic> data = doc.data();

            _transactions.add({
              "id": doc.id,
              "type": data['type'],
              "amount": data['amount'],
              "category": data['category'],
              "desc": data['desc'],
              "title": data['title'],
              "account": data['account'] ?? "Tunai", // AMBIL DATA AKUN
              "date": data['date'],
              "time": data['time'],
              "icon": data['type'] == 0
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              "color": data['type'] == 0 ? Colors.green : Colors.red,
            });

            // Hitung Saldo Global Transaksi
            int amount = data['amount'];
            if (data['type'] == 0) {
              _balance += amount;
              _totalIncome += amount;
            } else {
              _balance -= amount;
              _totalExpense += amount;
            }
          }
          notifyListeners();
        });
  }

  void resetData() {
    _transactions = [];
    _balance = 0; // Reset saldo
    _totalIncome = 0;
    _totalExpense = 0;
    notifyListeners();
  }

  // 2. TAMBAH TRANSAKSI (Updated dengan parameter Account)
  Future<void> addTransaction({
    required int type,
    required int amount,
    required String category,
    required String desc,
    required String account, // WAJIB: Nama rekening
  }) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .add({
            "type": type,
            "amount": amount,
            "category": category,
            "desc": desc,
            "account": account, // SIMPAN KE FIREBASE
            "title": desc.isNotEmpty
                ? desc
                : (type == 0 ? "Pemasukan Lain" : "Pengeluaran Lain"),
            "date": DateFormat('dd/MM/yyyy').format(DateTime.now()),
            "time": DateFormat('HH.mm').format(DateTime.now()) + " WIB",
            "createdAt": FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print("Gagal simpan transaksi: $e");
    }
  }

  static String formatRupiah(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(amount);
  }
}
