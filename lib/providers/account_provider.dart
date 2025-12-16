// lib/models/account_provider.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

// 1. Account Model
class AccountModel {
  final String id;
  final String title;
  String saldo; // Non-final
  String lastUsed; // Non-final
  final List<Color> colors;

  AccountModel({
    required this.id,
    required this.title,
    required this.saldo,
    required this.lastUsed,
    required this.colors,
  });
}

// 2. Account Provider
class AccountProvider extends ChangeNotifier {
  // FIX: Kosongkan list _accounts agar tidak ada data dummy
  final List<AccountModel> _accounts = []; 

  List<AccountModel> get accounts => _accounts;

  // Method untuk menghapus rekening
  void deleteAccount(String accountId) {
    _accounts.removeWhere((account) => account.id == accountId);
    notifyListeners();
  }

  // Method untuk menambah rekening
  void addAccount(AccountModel newAccount) {
    _accounts.add(newAccount);
    notifyListeners();
  }
  
  // METHOD: Menambah Saldo
  void updateAccountBalance(String accountId, double amountToAdd) {
    final accountIndex = _accounts.indexWhere((acc) => acc.id == accountId);
    if (accountIndex == -1) return;

    final account = _accounts[accountIndex];

    // 1. Bersihkan string saldo saat ini (hapus 'Rp' dan tanda pemisah ribuan)
    // Menggunakan RegExp(r'[Rp\.]') untuk menghapus literal 'Rp' dan titik '.'
    String currentSaldoString = account.saldo
        .replaceAll(RegExp(r'[Rp\.]'), '') 
        .replaceAll(',', '') 
        .trim();
        
    // 2. Konversi ke double dan hitung saldo baru
    double currentSaldo = double.tryParse(currentSaldoString) ?? 0.0;
    double newSaldo = currentSaldo + amountToAdd;

    // 3. Format saldo baru kembali ke string Rupiah
    final formatter = NumberFormat.currency(
        locale: 'id_ID', 
        symbol: 'Rp', 
        decimalDigits: 0
    );
    
    // 4. Update properti objek yang ada
    account.saldo = formatter.format(newSaldo);
    account.lastUsed = DateFormat('d/M/yyyy').format(DateTime.now());

    // 5. Beri tahu listener agar UI AccountsScreen terupdate
    notifyListeners();
  }
}