// lib/models/bill_provider.dart

import 'package:flutter/material.dart';

// 1. MODEL DATA BILL
class BillModel {
  final String name;
  final String amount;
  final String category;
  final String dueDate;
  final String status; 

  BillModel({
    required this.name,
    required this.amount,
    required this.category,
    required this.dueDate,
    this.status = 'Unpaid Bill',
  });
}

// 2. BILL PROVIDER (GLOBAL STATE MANAGEMENT)
class BillProvider extends ChangeNotifier {
  final List<BillModel> _allBills = [];

  List<BillModel> get allBills => _allBills;

  // Method untuk menambahkan bill baru
  void addBill(BillModel bill) {
    _allBills.add(bill);
    notifyListeners();
  }

  // METHOD BARU: Menandai tagihan sebagai Paid (Lunas)
  void markBillAsPaid(BillModel bill) {
    // Cari index tagihan berdasarkan nama dan tanggal jatuh tempo (asumsi kunci unik)
    final index = _allBills.indexWhere((b) => b.name == bill.name && b.dueDate == bill.dueDate); 
    
    if (index != -1) {
      // Buat objek BillModel baru dengan status 'Paid'
      _allBills[index] = BillModel(
        name: bill.name,
        amount: bill.amount,
        category: bill.category,
        dueDate: bill.dueDate,
        status: 'Paid', // Update status menjadi Paid
      );
      notifyListeners(); 
    }
  }
}