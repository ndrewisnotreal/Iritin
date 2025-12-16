import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iritin/providers/dashboard_provider.dart';
import 'package:iritin/providers/transaction_provider.dart'; // Sumber Data
import 'package:iritin/screens/dashboard/accounts_screen.dart';
import 'package:iritin/styling/app_colors.dart';

// FIX: Import AccountProvider dan AccountModel dari file providernya
import 'package:iritin/providers/account_provider.dart'; 
import 'package:iritin/providers/account_provider.dart' show AccountModel; 

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // 0: Pengeluaran, 1: Pemasukan
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    // 1. AMBIL DATA DARI PROVIDER
    final provider = context.watch<TransactionProvider>();
    final accountProvider = context.watch<AccountProvider>(); 
    final accountsList = accountProvider.accounts; // List akun

    // 2. SIAPKAN DATA STATISTIK
    final totalBudget = provider.totalIncome;
    final totalExpense = provider.totalExpense;
    final saldoAkhir = provider.balance;

    // 3. SIAPKAN DATA UNTUK CHART & LIST
    final int targetType = _selectedTab == 0 ? 1 : 0;

    // Ambil transaksi yang sesuai tab (Map-based)
    final filteredTrans = provider.transactions.where((t) => t['type'] == targetType).toList();

    // Grouping data per Kategori untuk Chart
    final Map<String, double> categoryData = {};
    double totalAmountInTab = 0;

    for (var t in filteredTrans) {
      final String cat = t['category'] ?? "Lainnya";
      // Pastikan 'amount' adalah integer di Map
      final double amount = (t['amount'] as int).toDouble(); 

      if (categoryData.containsKey(cat)) {
        categoryData[cat] = categoryData[cat]! + amount;
      } else {
        categoryData[cat] = amount;
      }
      totalAmountInTab += amount;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER (Kirim data statistik real)
            _buildHeader(context, totalBudget, totalExpense, saldoAkhir),

            const SizedBox(height: 20),
            _buildToggleSwitch(),

            const SizedBox(height: 20),

            // CHART (Kirim data kategori yang sudah diolah)
            _buildChartSection(categoryData, totalAmountInTab),

            const SizedBox(height: 20),

            // LIST KATEGORI (Dinamis)
            if (categoryData.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("Belum ada data untuk ditampilkan", style: TextStyle(color: Colors.grey)),
              )
            else
              _buildCategoryList(categoryData, totalAmountInTab),

            // Bagian Akun Rekening (Hanya muncul di tab Pemasukan)
            if (_selectedTab == 1) ...[
              const SizedBox(height: 24),
              _buildAccountSection(context, accountsList), 
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- 1. HEADER DINAMIS ---
  Widget _buildHeader(BuildContext context, int budget, int expense, int saldo) {
    // Hitung persentase sisa saldo untuk progress bar
    double progress = (budget == 0) ? 0 : (saldo / budget);
    if (progress < 0) progress = 0; 
    if (progress > 1) progress = 1; 

    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // FIX BLACK SCREEN: Gunakan DashboardProvider untuk closeSubPage
              GestureDetector(
                onTap: () {
                   // Perubahan Utama Ada Disini:
                   context.read<DashboardProvider>().closeSubPage(); 
                },
                child: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
              const SizedBox(width: 8),
              Text(
                "Dashboard Analytics - ${_selectedTab == 0 ? 'Pengeluaran' : 'Pemasukan'}",
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Overview Analytics",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          // Teks Saldo Dinamis
          Text(
            "Tersisa ${TransactionProvider.formatRupiah(saldo)} dari ${TransactionProvider.formatRupiah(budget)}",
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 15),

          // Progress Bar Dinamis
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white54,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(height: 20),

          // Statistik 3 Kolom
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("Total Pemasukan", TransactionProvider.formatRupiah(budget), Colors.purple),
              _buildStatItem("Total Pengeluaran", TransactionProvider.formatRupiah(expense), Colors.red),
              _buildStatItem("Saldo Akhir", TransactionProvider.formatRupiah(saldo), Colors.blue),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded( 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // --- 2. CHART DINAMIS ---
  Widget _buildChartSection(Map<String, double> data, double total) {
    if (total == 0) {
      return const SizedBox(height: 200, child: Center(child: Text("Belum ada transaksi")));
    }

    // Warna-warna untuk chart
    final List<Color> colors = [
      const Color(0xFFF06292), 
      const Color(0xFF4FC3F7), 
      const Color(0xFFFFB74D), 
      const Color(0xFF9575CD), 
      const Color(0xFF4DB6AC), 
      Colors.lime,
      Colors.indigo,
    ];

    int colorIndex = 0;

    // Buat Section Chart dari Data Map
    List<PieChartSectionData> sections = [];

    data.forEach((key, value) {
      final percentage = (value / total) * 100;
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: percentage,
          radius: 80,
          showTitle: false,
        ),
      );
      colorIndex++;
    });

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 0,
                sections: sections,
              ),
            ),
          ),
          // Legend (Keterangan Warna)
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.keys.toList().asMap().entries.map((entry) {
                int idx = entry.key;
                String name = entry.value;
                return _LegendItem(
                    color: colors[idx % colors.length],
                    text: name
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  // --- 3. LIST KATEGORI DINAMIS ---
  Widget _buildCategoryList(Map<String, double> data, double total) {
    // Ubah Map ke List biar bisa di-sort (terbesar di atas)
    var sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: sortedEntries.map((entry) {
          double percentage = entry.value / total;
          return _buildCategoryItem(
              entry.key,
              percentage,
              "${TransactionProvider.formatRupiah(entry.value.toInt())} / ${TransactionProvider.formatRupiah(total.toInt())}"
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryItem(String title, double percent, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(amount, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
  
  // --- 4. ACCOUNT SECTION DINAMIS ---
  Widget _buildAccountSection(BuildContext context, List<AccountModel> accounts) {
    // FIX: Logika utama - jika daftar akun kosong, tampilkan pesan.
    if (accounts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "Anda belum menambahkan rekening. Akun akan muncul di sini setelah ditambahkan.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Akun Rekening", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  // Navigasi ke AccountsScreen
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountsScreen()));
                },
                child: const Text("Lihat semua >", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            children: accounts.map((account) { 
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _buildAccountCard(
                    account.title, 
                    account.saldo, 
                    account.colors 
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Widget _buildAccountCard
  Widget _buildAccountCard(String title, String saldo, List<Color> colors) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          Text("Saldo: $saldo", style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
  
  // --- WIDGET LAINNYA ---

  Widget _buildToggleSwitch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Expanded(child: _buildToggleButton("Pengeluaran", 0)),
          Expanded(child: _buildToggleButton("Pemasukan", 1)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color, radius: 3),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}