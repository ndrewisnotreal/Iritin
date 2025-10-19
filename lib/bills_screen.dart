// lib/bills_screen.dart
import 'package:flutter/material.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  // Data Dummy untuk Konversi Mata Uang
  final double dummyRate = 16000.0;
  final double dummyAmount = 100.0;

  // Fungsi utilitas untuk format mata uang sederhana
  String _formatRupiah(double amount) => 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Dua tab: Tagihan dan Konversi Mata Uang
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fitur Lain'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.notifications_active), text: 'Pengingat Tagihan'),
              Tab(icon: Icon(Icons.currency_exchange), text: 'Konversi Mata Uang'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: Pengingat Tagihan (Bill Reminder)
            _buildBillReminderTab(context),

            // TAB 2: Konversi Mata Uang (Exchange Currency)
            _buildCurrencyExchangeTab(),
          ],
        ),
      ),
    );
  }

  // Sub-widget untuk Tab Pengingat Tagihan
  Widget _buildBillReminderTab(BuildContext context) {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Tagihan yang Harus Dibayar:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        ListTile(
          leading: const Icon(Icons.warning, color: Colors.red),
          title: const Text('Tagihan Listrik'),
          subtitle: const Text('Rp 350.000 - LEWAT JATUH TEMPO!'),
          trailing: IconButton(icon: const Icon(Icons.payment), onPressed: () {}),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.calendar_today, color: Colors.orange),
          title: const Text('WiFi Indihome'),
          subtitle: const Text('Rp 420.000 - Jatuh Tempo: 3 Hari Lagi'),
          trailing: IconButton(icon: const Icon(Icons.payment), onPressed: () {}),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: const Text('Cicilan Motor'),
          subtitle: const Text('Status: LUNAS Bulan Ini'),
          trailing: TextButton(onPressed: () {}, child: const Text('Siklus Baru')),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              // Di sini nanti bisa navigasi ke halaman input tagihan
            },
            icon: const Icon(Icons.add_alert),
            label: const Text('Tambah Pengingat Tagihan'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
          ),
        )
      ],
    );
  }

  // Sub-widget untuk Tab Konversi Mata Uang
  Widget _buildCurrencyExchangeTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Konversi Mata Uang (Integrasi API)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Jumlah Mata Uang Asing (Misal: 100 USD)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Text('Rate Dummy: 1 USD = ${_formatRupiah(dummyRate)}'),
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Hasil Konversi (IDR):', style: TextStyle(fontSize: 18)),
                Text(
                  _formatRupiah(dummyAmount * dummyRate), // Hasil 100 * 16000
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 45),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cek Kurs Saat Ini (Simulasi API)', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}