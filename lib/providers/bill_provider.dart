// lib/providers/bill_provider.dart (FULL FIX)

import 'package:flutter/material.dart';
// Import BillModel yang benar dari models/
import '../models/bill_model.dart'; 

// HAPUS DEFINISI DUPLIKAT BillModel LAMA DI SINI (Model Data Bill)

// 2. BILL PROVIDER (GLOBAL STATE MANAGEMENT)
class BillProvider extends ChangeNotifier {
  // List sekarang menggunakan BillModel yang benar
  final List<BillModel> _allBills = []; 

  List<BillModel> get allBills => _allBills;

  // Method untuk menambahkan bill baru
  void addBill(BillModel bill) {
    _allBills.add(bill);
    notifyListeners();
  }

  // METHOD: Menandai tagihan sebagai Paid (Lunas)
  void markBillAsPaid(BillModel bill) {
    // Cari index tagihan berdasarkan nama dan tanggal jatuh tempo (sesuai kode asli user)
    final index = _allBills.indexWhere((b) => b.name == bill.name && b.dueDate == bill.dueDate); 
    
    if (index != -1) {
      final existingBill = _allBills[index];
      
      // Buat objek BillModel baru (dari models/bill_model.dart)
      // Gunakan named constructor untuk mempertahankan ID dan Notes yang ada di existingBill
      _allBills[index] = BillModel(
        id: existingBill.id, // Pertahankan ID
        name: existingBill.name,
        amount: existingBill.amount,
        category: existingBill.category,
        dueDate: existingBill.dueDate,
        notes: existingBill.notes, // Pertahankan Notes
        status: 'Paid', // Update status menjadi Paid
      );
      notifyListeners(); 
    }
  }
}