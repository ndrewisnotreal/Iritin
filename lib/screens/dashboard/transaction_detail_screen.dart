import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iritin/providers/dashboard_provider.dart';
import 'package:iritin/providers/transaction_provider.dart';
import 'package:iritin/styling/app_colors.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const TransactionDetailScreen({super.key, required this.data});

  // --- HELPER: KATEGORI & WARNA ---
  Map<String, dynamic> _getCategoryDetails(String categoryName) {
    final Map<String, dynamic> categoryMap = {
      'Pendidikan': {'icon': Icons.school, 'color': Colors.blue},
      'Makanan': {'icon': Icons.restaurant, 'color': Colors.red},
      'Fashion': {'icon': Icons.checkroom, 'color': Colors.pink},
      'Hiburan': {'icon': Icons.sports_esports, 'color': Colors.purple},
      'Transportasi': {'icon': Icons.directions_bus, 'color': Colors.orange},
      'Tagihan': {'icon': Icons.lightbulb, 'color': Colors.brown},
      'Upah': {'icon': Icons.payments, 'color': Colors.green},
      'Bisnis': {'icon': Icons.store, 'color': Colors.teal},
      'Bunga': {'icon': Icons.trending_up, 'color': Colors.indigo},
      'Insentif': {'icon': Icons.star, 'color': Colors.amber},
      'Lainnya': {'icon': Icons.more_horiz, 'color': Colors.grey},
    };

    return categoryMap[categoryName] ??
        {'icon': Icons.category, 'color': Colors.grey};
  }

  @override
  Widget build(BuildContext context) {
    final categoryDetails = _getCategoryDetails(data['category'] ?? 'Lainnya');
    final IconData itemIcon = categoryDetails['icon'];
    final Color itemColor = categoryDetails['color'];
    final bool isExpense = data['type'] == 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Background Abu-abu
      appBar: AppBar(
        title: const Text(
          "Detail Transaksi",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary, // Warna Lime
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.read<DashboardProvider>().closeSubPage(),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. KARTU UTAMA (ICON & JUMLAH)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: itemColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(itemIcon, size: 40, color: itemColor),
                  ),
                  const SizedBox(height: 16),

                  // Judul
                  Text(
                    data['title'] ?? "Transaksi", // Menggunakan judul default jika kosong
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['category'] ?? "Umum",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 24),

                  // Nominal
                  Text(
                    TransactionProvider.formatRupiah(data['amount']),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isExpense
                          ? const Color(0xFFE53935)
                          : const Color(0xFF2962FF), // Menggunakan warna biru untuk pemasukan agar beda dengan header
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isExpense
                          ? Colors.red.shade50
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isExpense ? "Pengeluaran" : "Pemasukan",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isExpense ? Colors.red : Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. KARTU DETAIL INFORMASI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informasi Tambahan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  _buildFlatRow("Tanggal", data['date'] ?? "-"),
                  const Divider(height: 24, color: Colors.black12),

                  _buildFlatRow("Waktu", data['time'] ?? "-"),
                  const Divider(height: 24, color: Colors.black12),

                  // --- BAGIAN INI YANG SUDAH DINAMIS ---
                  _buildFlatRow("Akun", data['account'] ?? "Tunai"), 
                  // -------------------------------------
                  
                  const Divider(height: 24, color: Colors.black12),

                  _buildFlatRow(
                    "Catatan",
                    (data['desc'] != null && data['desc'].toString().isNotEmpty)
                        ? data['desc']
                        : "-",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Baris Flat Sederhana
  Widget _buildFlatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}