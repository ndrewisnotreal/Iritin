import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iritin/providers/dashboard_provider.dart';
import 'package:iritin/providers/transaction_provider.dart'; // <--- Penting
import 'package:iritin/screens/dashboard/transaction_detail_screen.dart';
import 'package:iritin/styling/app_colors.dart'; // Asumsi AppColors.primary tersedia

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedTab = 0; // 0: Pengeluaran, 1: Pemasukan
  int _selectedCategoryIndex = 0;
  String _searchQuery = ''; // State untuk input pencarian

  // --- DATA KATEGORI GLOBAL (Digunakan untuk mencocokkan Ikon/Warna) ---
  final Map<String, dynamic> _categoryDataMap = {
    // Pengeluaran (type: 1)
    'Pendidikan': {'icon': Icons.school, 'color': Colors.blue, 'type': 1},
    'Makanan': {'icon': Icons.restaurant, 'color': Colors.red, 'type': 1},
    'Fashion': {'icon': Icons.checkroom, 'color': Colors.pink, 'type': 1},
    'Hiburan': {'icon': Icons.sports_esports, 'color': Colors.purple, 'type': 1},
    'Transportasi': {'icon': Icons.directions_bus, 'color': Colors.orange, 'type': 1},
    'Tagihan': {'icon': Icons.lightbulb, 'color': Colors.brown, 'type': 1},
    // Pemasukan (type: 0)
    'Upah': {'icon': Icons.payments, 'color': Colors.green.shade700, 'type': 0},
    'Bisnis': {'icon': Icons.store, 'color': Colors.teal, 'type': 0},
    'Bunga': {'icon': Icons.trending_up, 'color': Colors.indigo, 'type': 0},
    'Insentif': {'icon': Icons.star, 'color': Colors.amber, 'type': 0},
    // Lainnya / Default
    'Lainnya': {'icon': Icons.more_horiz, 'color': Colors.grey, 'type': -1},
  };
  // --------------------------------------------------------------------

  // Helper untuk mendapatkan IconData berdasarkan nama kategori
  Map<String, dynamic> _getCategoryDetails(String categoryName) {
    // Coba cari data kategori yang spesifik
    final details = _categoryDataMap[categoryName];
    if (details != null) {
      return details;
    }
    // Kembalikan default jika tidak ditemukan
    return _categoryDataMap['Lainnya'] ?? {'icon': Icons.help_outline, 'color': Colors.grey, 'type': -1};
  }

  // Getter untuk mendapatkan list kategori yang relevan untuk filter chips
  List<String> get _categoryFilterNames {
    final int targetType = _selectedTab == 0 ? 1 : 0;
    
    // 1. Ambil semua kategori yang sesuai dengan tipe saat ini
    final relevantCategories = _categoryDataMap.keys.where((key) {
      final type = _categoryDataMap[key]['type'];
      // Jika type -1, itu 'Lainnya', selalu masukkan
      return type == targetType || key == 'Lainnya';
    }).toList();
    
    // 2. Tambahkan 'Semua' di awal
    return ["Semua", ...relevantCategories];
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final int targetType = _selectedTab == 0 ? 1 : 0;
    final categories = _categoryFilterNames;
    
    // Tentukan kategori yang dipilih dari chip
    final selectedCategoryName = categories[_selectedCategoryIndex];

    // 2. LOGIKA FILTER & SEARCH
    final currentList = provider.transactions.where((item) {
      final matchesType = item['type'] == targetType;
      
      // Filter Kategori
      final matchesCategory = selectedCategoryName == "Semua" || item['category'] == selectedCategoryName;
      
      // Filter Search
      final matchesSearch = item['title'].toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            item['category'].toLowerCase().contains(_searchQuery.toLowerCase());
                            
      return matchesType && matchesCategory && matchesSearch;
    }).toList();


    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header & Toggle
            _buildTopSection(),

            // 2. Filter Kategori
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(categories.length, (index) {
                  return _buildCategoryChip(categories[index], index);
                }),
              ),
            ),

            // 3. Search Bar
            const SizedBox(height: 16),
            _buildSearchAndTools(),

            // 4. List Header
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "History",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey.shade300, height: 1),
                ],
              ),
            ),

            // 5. LIST ITEM (DINAMIS)
            Expanded(
              child: currentList.isEmpty
                  ? _buildEmptyState() // Tampilkan kalau kosong
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: currentList.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        // Dibalik urutannya supaya yang baru input muncul paling atas
                        final item = currentList[currentList.length - 1 - index];
                        return _buildTransactionItem(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // TAMPILAN KOSONG (Logika tidak berubah)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Belum ada riwayat ${_selectedTab == 0 ? 'Pengeluaran' : 'Pemasukan'}",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ITEM TRANSAKSI (Diperbarui untuk Ikon dan Warna)
  Widget _buildTransactionItem(Map<String, dynamic> item) {
    bool isExpense = item['type'] == 1;
    final categoryDetails = _getCategoryDetails(item['category']);

    final itemIcon = categoryDetails['icon'] as IconData;
    final itemColor = categoryDetails['color'] as Color;

    return GestureDetector(
      onTap: () {
        // Navigasi ke Detail Transaksi
        context.read<DashboardProvider>().openSubPage(
          TransactionDetailScreen(data: item),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFDFD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon DARI KATEGORI
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                // Menggunakan warna kategori dengan opacity rendah
                color: itemColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                itemIcon, // Ikon dari kategori
                color: itemColor, // Warna dari kategori
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Text Detail
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? 'Transaksi',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['category'] ?? 'Umum',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isExpense
                          ? const Color(0xFFFFEBEE)
                          : const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      TransactionProvider.formatRupiah(item['amount'] ?? 0),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isExpense
                            ? const Color(0xFFE53935)
                            : const Color(0xFF2962FF),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Waktu & Panah Detail
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item['date'] ?? '-',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  item['time'] ?? '-',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
                const SizedBox(height: 12),
                const Icon(Icons.chevron_right, color: Colors.blue, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- BAGIAN HEADER & SEARCH ---

  Widget _buildTopSection() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 20),
      child: Column(
        children: [
          const Text(
            "Riwayat Transaksi",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _buildTabButton("Pengeluaran", 0),
                _buildTabButton("Pemasukan", 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedTab = index;
          // Reset filter kategori saat tab berubah
          _selectedCategoryIndex = 0;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ]
                : [],
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
      ),
    );
  }

  Widget _buildCategoryChip(String label, int index) {
    bool isSelected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryIndex = index),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          // FIX: Warna chip dibuat lebih konsisten
          color: isSelected ? const Color(0xFF558B2F) : const Color(0xFFF9FCDF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF558B2F),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndTools() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FCDF),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Cari transaksi...",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search, color: const Color(0xFF558B2F)),
                  contentPadding: const EdgeInsets.only(bottom: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.calendar_today_outlined,
            color: Color(0xFF558B2F),
            size: 24,
          ),
          const SizedBox(width: 12),
          const Icon(Icons.tune, color: Color(0xFF558B2F), size: 24),
        ],
      ),
    );
  }
}