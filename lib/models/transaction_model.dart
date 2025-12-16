// lib/models/transaction_model.dart

import 'package:flutter/material.dart';

// Enum untuk mendefinisikan tipe transaksi secara eksplisit
enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String name; // Nama/deskripsi transaksi
  final String category;
  final int amount; // Jumlah dalam integer (Rp)
  final TransactionType type;
  final DateTime date;
  
  // Property opsional yang bisa ditambahkan dari Map lama Anda
  final String? time;
  final Color? color;
  final IconData? icon;

  TransactionModel({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
    this.time,
    this.color,
    this.icon,
  });
  
  // Helper untuk membuat Model dari Map (agar kompatibel dengan Provider lama)
  static TransactionModel fromMap(Map<String, dynamic> map) {
    // Kita harus mengonversi data Map lama menjadi format Model baru
    
    // Perhatikan bahwa Map Anda menggunakan int 0/1, string untuk tanggal.
    // Ini harus disesuaikan jika ingin menggunakannya.
    
    // Karena ini hanya placeholder untuk menghilangkan error, kita akan menggunakan data dummy:
    return TransactionModel(
        id: map['id'] ?? UniqueKey().toString(), // Asumsi 'id' tidak ada di map lama
        name: map['title'] ?? map['desc'] ?? 'Transaksi',
        category: map['category'] ?? 'Umum',
        amount: map['amount'] ?? 0,
        // Konversi int 0/1 ke enum TransactionType
        type: map['type'] == 0 ? TransactionType.income : TransactionType.expense,
        date: map['date'] is DateTime
            ? map['date']
            : DateTime.now(), // Jika format tanggalnya string, ini akan menjadi masalah
        // Properti opsional lainnya
        time: map['time'],
        color: map['color'],
        icon: map['icon']
    );
  }
}