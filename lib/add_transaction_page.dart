import 'package:flutter/material.dart';
import 'package:iritin/transaction_model.dart'; // Impor model

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  // Controller untuk mengambil teks dari input
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  
  TransactionType _selectedType = TransactionType.pengeluaran;

  void _submitData() {
    final enteredDescription = _descriptionController.text;
    final enteredAmount = double.tryParse(_amountController.text) ?? 0.0;

    // Validasi sederhana: pastikan deskripsi & jumlah tidak kosong
    if (enteredDescription.isEmpty || enteredAmount <= 0) {
      return; // Jangan lakukan apa-apa jika data tidak valid
    }

    // Buat objek transaksi baru
    final newTransaction = Transaction(
      description: enteredDescription,
      amount: enteredAmount,
      date: DateTime.now(),
      type: _selectedType, // <-- Gunakan state yang dipilih
    );

    // KIRIM BALIK data ke halaman sebelumnya
    Navigator.of(context).pop(newTransaction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TOMBOL PILIHAN JENIS TRANSAKSI
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(value: TransactionType.pengeluaran, label: Text('Pengeluaran')),
                ButtonSegment(value: TransactionType.pemasukan, label: Text('Pemasukan')),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<TransactionType> newSelection) {
                setState(() {
                  _selectedType = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi (Cth: Beli Kopi)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitData,
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}