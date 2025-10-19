
import 'package:flutter/material.dart';
import 'package:iritin/add_transaction_page.dart';
import 'package:iritin/transaction_model.dart';

class DashboardPage extends StatelessWidget {
  // Terima data dan fungsi dari MainScreen
  final List<Transaction> transactions;
  final Function(Transaction) addTransaction;

  const DashboardPage({
    super.key,
    required this.transactions,
    required this.addTransaction,
  });

  // --- Perhitungan Data ---
  double get totalPemasukan => transactions
      .where((tx) => tx.type == TransactionType.pemasukan)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalPengeluaran => transactions
      .where((tx) => tx.type == TransactionType.pengeluaran)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get uangKamuSekarang => totalPemasukan - totalPengeluaran;

  // Navigasi yang melempar data kembali ke MainScreen
  void _navigateAndAddTransaction(BuildContext context) async {
    final newTransaction = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionPage()),
    );

    if (newTransaction != null) {
      // Panggil fungsi yang diterima dari MainScreen untuk menyimpan data
      addTransaction(newTransaction);
    }
  }

  // Fungsi utilitas untuk format mata uang sederhana
  String _formatRupiah(double amount) => amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iritin - Dashboard'),
      ),
      // MENGHAPUS SingleChildScrollView AGAR BODY HANYA BERISI KARTU
      body: Column( // Menggunakan Column karena hanya ada satu widget di dalamnya
        children: [
            // WIDGET 1: HANYA KARTU RINGKASAN SALDO
            _buildSummaryCard(),

            // ************ SEMUA WIDGET DI BAWAH KARTU TELAH DIHAPUS ************
            // Tempat ini sekarang kosong (flex space)
        ],
      ),
      // FAB tetap di dashboard untuk memicu input
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndAddTransaction(context),
        tooltip: 'Tambah Transaksi',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget untuk Kartu Ringkasan
  Widget _buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("UANG KAMU SEKARANG", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Rp ${_formatRupiah(uangKamuSekarang)}", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.teal)),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_upward, color: Colors.green),
                    const SizedBox(width: 8),
                    Text("Total Pemasukan\nRp ${_formatRupiah(totalPemasukan)}", style: const TextStyle(color: Colors.green)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.arrow_downward, color: Colors.red),
                    const SizedBox(width: 8),
                    Text("Total Pengeluaran\nRp ${_formatRupiah(totalPengeluaran)}", style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}