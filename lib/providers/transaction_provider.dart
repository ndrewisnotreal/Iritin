import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Kita butuh ini buat format Rp

class TransactionProvider extends ChangeNotifier {
  // 1. Data Utama (Saldo Awal 0)
  int _balance = 0; // Saldo saat ini
  int _totalExpense = 0; // Total Pengeluaran
  int _totalIncome = 0; // Total Pemasukan

  // 2. List Transaksi (Awalnya Kosong)
  // Kita simpan dalam bentuk Map dulu biar simpel
  List<Map<String, dynamic>> _transactions = [];

  // 3. Getter (Biar bisa dibaca UI)
  int get balance => _balance;
  int get totalExpense => _totalExpense;
  int get totalIncome => _totalIncome;
  List<Map<String, dynamic>> get transactions => _transactions;

  // 4. Helper Format Rupiah
  static String formatRupiah(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(amount);
  }

  void addTransaction({
    required int type, // 0: Pemasukan, 1: Pengeluaran
    required int amount,
    required String category,
    required String desc,
  }) {
    // 1. Buat Map Transaksi
    final newTransaction = {
      "type": type,
      "amount": amount,
      "category": category,
      "desc": desc,
      "title": desc.isNotEmpty
          ? desc
          : (type == 0 ? "Pemasukan Lain" : "Pengeluaran Lain"),
      "date": DateFormat(
        'dd/MM/yyyy',
      ).format(DateTime.now()), // Tanggal hari ini
      "time":
          DateFormat('HH.mm').format(DateTime.now()) + " WIB", // Jam sekarang
      "icon": type == 0
          ? Icons.arrow_downward
          : Icons.arrow_upward, // Icon sementara
      "color": type == 0 ? Colors.green : Colors.red, // Warna icon
    };

    // 2. Masukkan ke List (paling depan biar jadi terbaru)
    _transactions.add(newTransaction);

    // 3. Update Saldo & Total
    if (type == 0) {
      // Pemasukan
      _balance += amount;
      _totalIncome += amount;
    } else {
      // Pengeluaran
      _balance -= amount;
      _totalExpense += amount;
    }

    // 4. Kabari semua layar (Home & History) kalau data berubah
    notifyListeners();
  }

  // Nanti kita tambah fungsi addTransaction disini...
}
