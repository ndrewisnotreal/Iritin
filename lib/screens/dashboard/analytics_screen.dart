import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iritin/providers/dashboard_provider.dart';
import 'package:iritin/providers/transaction_provider.dart';
import 'package:iritin/models/account_provider.dart'; 
import 'package:iritin/screens/dashboard/accounts_screen.dart';
import 'package:iritin/styling/app_colors.dart';

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
    // 1. Ambil data dari Provider
    final transProvider = context.watch<TransactionProvider>();
    final accountProvider = context.watch<AccountProvider>(); 

    final totalBudget = transProvider.totalIncome;
    final totalExpense = transProvider.totalExpense;
    final saldoAkhir = transProvider.balance;

    // 2. Filter data berdasarkan tab aktif
    final int targetType = _selectedTab == 0 ? 1 : 0;
    final filteredTrans = transProvider.transactions
        .where((t) => t['type'] == targetType)
        .toList();

    // 3. Olah data kategori untuk Chart
    final Map<String, double> categoryData = {};
    double totalAmountInTab = 0;

    for (var t in filteredTrans) {
      final String cat = t['category'] ?? "Lainnya";
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
            // Header Statistik
            _buildHeader(context, totalBudget, totalExpense, saldoAkhir),

            const SizedBox(height: 20),
            _buildToggleSwitch(),

            const SizedBox(height: 20),

            // Bagian Chart dengan Persentase
            _buildChartSection(categoryData, totalAmountInTab),

            const SizedBox(height: 20),

            // List Kategori Dinamis
            if (categoryData.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Belum ada data untuk ditampilkan",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              _buildCategoryList(categoryData, totalAmountInTab),

            // Bagian Akun Rekening Real (Hanya muncul di tab Pemasukan)
            if (_selectedTab == 1) ...[
              const SizedBox(height: 24),
              _buildAccountSection(context, accountProvider.accounts),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- 1. HEADER ---
  Widget _buildHeader(BuildContext context, int budget, int expense, int saldo) {
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
              GestureDetector(
                onTap: () => context.read<DashboardProvider>().closeSubPage(),
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
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            "Tersisa ${TransactionProvider.formatRupiah(saldo)} dari ${TransactionProvider.formatRupiah(budget)}",
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 15),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("Total Pemasukan", TransactionProvider.formatRupiah(budget), Colors.purple),
              _buildStatItem("Total Pengeluaran", TransactionProvider.formatRupiah(expense), Colors.red),
              _buildStatItem("Saldo Akhir", TransactionProvider.formatRupiah(saldo), Colors.blue),
            ],
          ),
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

  // --- 2. CHART DENGAN PERSENTASE ---
  Widget _buildChartSection(Map<String, double> data, double total) {
    if (total == 0) return const SizedBox(height: 200, child: Center(child: Text("Belum ada transaksi")));

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
    List<PieChartSectionData> sections = [];

    data.forEach((key, value) {
      final double percentage = (value / total) * 100;
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: value,
          radius: 80,
          showTitle: true,
          title: "${percentage.toStringAsFixed(1)}%",
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
          ),
          titlePositionPercentageOffset: 0.5,
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
            child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 0, sections: sections)),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.keys.toList().asMap().entries.map((entry) {
                return _LegendItem(color: colors[entry.key % colors.length], text: entry.value);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. AKUN REKENING REAL ---
  Widget _buildAccountSection(BuildContext context, List<AccountModel> accounts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Akun Rekening", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(
                // PERBAIKAN DI SINI: Gunakan Navigator.push agar tombol back di AccountsScreen bekerja
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountsScreen()),
                ),
                child: const Text("Lihat semua >", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (accounts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text("Belum ada akun rekening.", style: TextStyle(color: Colors.grey, fontSize: 13)),
          )
        else
          SizedBox(
            height: 160,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final acc = accounts[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildAccountCard(acc.title, acc.saldo, acc.colors),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildAccountCard(String title, String saldo, List<Color> colors) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors.isNotEmpty ? colors : [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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

  // --- TOGGLE & LIST ITEM ---
  Widget _buildToggleSwitch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(50)),
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
        child: Center(child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.grey))),
      ),
    );
  }

  Widget _buildCategoryList(Map<String, double> data, double total) {
    var sortedEntries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: sortedEntries.map((entry) {
          return _buildCategoryItem(entry.key, entry.value / total, "${TransactionProvider.formatRupiah(entry.value.toInt())}");
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
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [CircleAvatar(backgroundColor: color, radius: 3), const SizedBox(width: 6), Text(text, style: const TextStyle(fontSize: 10))]),
    );
  }
}