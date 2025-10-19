// lib/history_page.dart (MODIFIKASI TOTAL)

import 'package:flutter/material.dart';
import 'package:iritin/transaction_model.dart'; // Impor model

class HistoryPage extends StatelessWidget {
  // Terima data transaksi dari MainScreen
  final List<Transaction> transactions;
  
  const HistoryPage({super.key, required this.transactions});

  // Fungsi utilitas untuk format mata uang sederhana
  String _formatRupiah(double amount) => amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
      ),
      body: Column(
        children: [
          // Filter Periode (tetap sebagai placeholder, data yang ditampilkan semua)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Filter Periode (Semua Transaksi)',
              ),
              items: ['Bulan Ini', 'Bulan Lalu', 'Semua']
                  .map((label) => DropdownMenuItem(
                        value: label,
                        child: Text(label),
                      ))
                  .toList(),
              value: 'Semua', // Set default
              onChanged: (value) {},
            ),
          ),

          // Tampilkan semua daftar transaksi
          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: Text('Belum ada riwayat transaksi.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: transactions.length, // Tampilkan SEMUA transaksi
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      final isExpense = tx.type == TransactionType.pengeluaran;
                      final color = isExpense ? Colors.red : Colors.green;
                      final icon = isExpense ? Icons.arrow_downward : Icons.arrow_upward;
                      final prefix = isExpense ? '- ' : '+ ';

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                        child: ListTile(
                          leading: Icon(icon, color: color, size: 40),
                          title: Text(tx.description, style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text('Tgl: ${tx.date.day}/${tx.date.month}/${tx.date.year}'),
                          trailing: Text(
                            '$prefix Rp ${_formatRupiah(tx.amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}