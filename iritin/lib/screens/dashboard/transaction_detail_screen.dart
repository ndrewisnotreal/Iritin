import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iritin/providers/dashboard_provider.dart';
import 'package:iritin/providers/transaction_provider.dart'; // Import ini untuk format Rupiah
import 'package:iritin/styling/app_colors.dart';

class TransactionDetailScreen extends StatelessWidget {
  // Menerima data transaksi dari halaman sebelumnya
  final Map<String, dynamic> data;

  const TransactionDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Cek apakah ini pengeluaran (type 1) atau pemasukan (type 0)
    bool isExpense = data['type'] == 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER HIJAU
            _buildHeader(context),

            // 2. KARTU DETAIL (Kuning Muda)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDetailCard(),
                  const SizedBox(height: 24),

                  // 3. TOMBOL AKSI (Edit & Hapus)
                  Row(
                    children: [
                      // Tombol EDIT (Kuning Lime)
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD2F801),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            // Nanti kita buat fitur edit di sini
                          },
                          child: const Text(
                            "Edit",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Tombol HAPUS (Merah)
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            _showDeleteDialog(context);
                          },
                          child: const Text(
                            "Hapus",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Spacer agar konten tidak tertutup navbar
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 40),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Baris Atas: Tombol Back & Judul
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Menutup halaman detail dan kembali ke list history
                  context.read<DashboardProvider>().closeSubPage();
                },
                child: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: const Text(
                      "Rangkuman Transaksi",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Icon Besar di Tengah
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            // Menggunakan icon dari data, atau default jika tidak ada
            child: Icon(
              data['icon'] ?? Icons.monetization_on,
              size: 50,
              color: Colors.green.shade800,
            ),
          ),

          const SizedBox(height: 16),

          // Judul Transaksi (Misal: Gajian)
          Text(
            data['title'] ?? "Transaksi",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          // Kategori (Misal: Upah)
          Text(
            data['category'] ?? "Umum",
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard() {
    // Format angka ke Rupiah menggunakan helper dari TransactionProvider
    String formattedAmount = TransactionProvider.formatRupiah(
      data['amount'] ?? 0,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FCDF), // Warna latar kartu (kuning muda/krem)
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRowItem("Tanggal", data['date'] ?? "-"),
          const Divider(height: 1, color: Colors.black12),
          _buildRowItem("Waktu", data['time'] ?? "-"),
          const Divider(height: 1, color: Colors.black12),
          _buildRowItem("Akun", "Kartu Debit"), // Bisa dibuat dinamis nanti
          const Divider(height: 1, color: Colors.black12),
          _buildRowItem("Jumlah", formattedAmount),
          const Divider(height: 1, color: Colors.black12),
          _buildRowItem("Note", data['desc'] ?? "-", isLast: true),
        ],
      ),
    );
  }

  Widget _buildRowItem(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- POPUP HAPUS TRANSAKSI ---
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Sampah Merah
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF9A9A), // Latar merah muda icon
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  "Hapus Transaksi?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Transaksi akan terhapus dan tidak dapat dipulihkan kembali. Apakah anda yakin?",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    // Tombol Batal
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD2F801),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Batal",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Tombol Hapus
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          // Disini nanti kita tambahkan logic hapus dari provider
                          Navigator.pop(context); // Tutup Dialog
                          context
                              .read<DashboardProvider>()
                              .closeSubPage(); // Balik ke List

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Transaksi berhasil dihapus"),
                            ),
                          );
                        },
                        child: const Text(
                          "Hapus",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
