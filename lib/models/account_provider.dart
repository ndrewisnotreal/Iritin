import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 1. Account Model
class AccountModel {
  final String id;
  final String title;
  String saldo;
  String lastUsed;
  final List<Color> colors;

  AccountModel({
    required this.id,
    required this.title,
    required this.saldo,
    required this.lastUsed,
    required this.colors,
  });

  // Konversi dari Firebase
  factory AccountModel.fromMap(Map<String, dynamic> map, String docId) {
    return AccountModel(
      id: docId,
      title: map['title'] ?? '',
      saldo: map['saldo'] ?? 'Rp0',
      lastUsed: map['lastUsed'] ?? '',
      colors:
          (map['colors'] as List<dynamic>?)
              ?.map((c) => Color(c as int))
              .toList() ??
          [Colors.blue, Colors.blueAccent],
    );
  }

  // Konversi ke Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'saldo': saldo,
      'lastUsed': lastUsed,
      'colors': colors.map((c) => c.value).toList(),
      'userId': FirebaseAuth.instance.currentUser?.uid,
    };
  }
}

// 2. Account Provider
class AccountProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- PERBAIKAN DI SINI ---
  // HAPUS kata 'final'. Gunakan 'List<AccountModel>' saja agar bisa di-reset.
  List<AccountModel> _accounts = [];

  List<AccountModel> get accounts => _accounts;

  // --- FUNGSI RESET (SAPU JAGAT) ---
  void resetData() {
    _accounts = []; // Sekarang ini TIDAK akan error
    notifyListeners();
  }

  // --- 1. FETCH DARI FIREBASE ---
  Future<void> fetchAccounts() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await _firestore
          .collection('accounts')
          .where('userId', isEqualTo: uid)
          .get();

      _accounts = snapshot.docs
          .map((doc) => AccountModel.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      print("Error fetching accounts: $e");
    }
  }

  // --- 2. ADD ACCOUNT ---
  Future<void> addAccount(AccountModel newAccount) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final docRef = await _firestore
          .collection('accounts')
          .add(newAccount.toMap());

      // Update list lokal
      _accounts.add(
        AccountModel(
          id: docRef.id,
          title: newAccount.title,
          saldo: newAccount.saldo,
          lastUsed: newAccount.lastUsed,
          colors: newAccount.colors,
        ),
      );

      notifyListeners();
    } catch (e) {
      print("Error adding account: $e");
    }
  }

  // --- 3. DELETE ACCOUNT ---
  Future<void> deleteAccount(String accountId) async {
    try {
      await _firestore.collection('accounts').doc(accountId).delete();
      _accounts.removeWhere((account) => account.id == accountId);
      notifyListeners();
    } catch (e) {
      print("Error deleting account: $e");
    }
  }

  // --- 4. UPDATE SALDO ---
  Future<void> updateAccountBalance(
    String accountId,
    double amountToAdd,
  ) async {
    final accountIndex = _accounts.indexWhere((acc) => acc.id == accountId);
    if (accountIndex == -1) return;

    final account = _accounts[accountIndex];

    String currentSaldoString = account.saldo
        .replaceAll(RegExp(r'[Rp\.]'), '')
        .replaceAll(',', '')
        .trim();

    double currentSaldo = double.tryParse(currentSaldoString) ?? 0.0;
    double newSaldo = currentSaldo + amountToAdd;

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    String formattedSaldo = formatter.format(newSaldo);
    String now = DateFormat('d/M/yyyy').format(DateTime.now());

    try {
      await _firestore.collection('accounts').doc(accountId).update({
        'saldo': formattedSaldo,
        'lastUsed': now,
      });

      account.saldo = formattedSaldo;
      account.lastUsed = now;
      notifyListeners();
    } catch (e) {
      print("Error updating balance: $e");
    }
  }
}
