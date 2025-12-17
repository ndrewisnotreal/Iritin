import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iritin/providers/transaction_provider.dart';
// Pastikan path ini benar jika Anda sudah membuat detail screen
import 'package:iritin/screens/dashboard/transaction_detail_screen.dart';

// --- WARNA & KONSTANTA ---
const Color primaryGreen = Color(0xFFD1F333); 
const Color accentGreen = Color(0xFFF2FFB0);
const Color textColor = Color(0xFF2E4053);
const Color darkGreen = Color(0xFF558B2F);

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedTab = 0; // 0: Pengeluaran, 1: Pemasukan
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;

  // --- DATA KATEGORI ---
  final Map<String, dynamic> _categoryDataMap = {
    'Pendidikan': {'icon': Icons.school, 'color': Colors.blue, 'type': 1},
    'Makanan': {'icon': Icons.restaurant, 'color': Colors.red, 'type': 1},
    'Fashion': {'icon': Icons.checkroom, 'color': Colors.pink, 'type': 1},
    'Hiburan': {'icon': Icons.sports_esports, 'color': Colors.purple, 'type': 1},
    'Transportasi': {'icon': Icons.directions_bus, 'color': Colors.orange, 'type': 1},
    'Tagihan': {'icon': Icons.lightbulb, 'color': Colors.brown, 'type': 1},
    'Upah': {'icon': Icons.payments, 'color': Colors.green.shade700, 'type': 0},
    'Bisnis': {'icon': Icons.store, 'color': Colors.teal, 'type': 0},
    'Bunga': {'icon': Icons.trending_up, 'color': Colors.indigo, 'type': 0},
    'Insentif': {'icon': Icons.star, 'color': Colors.amber, 'type': 0},
    'Lainnya': {'icon': Icons.more_horiz, 'color': Colors.grey, 'type': -1},
  };

  Map<String, dynamic> _getCategoryDetails(String categoryName) {
    final details = _categoryDataMap[categoryName];
    if (details != null) return details;
    return _categoryDataMap['Lainnya']!;
  }

  List<String> get _categoryFilterNames {
    final int targetType = _selectedTab == 0 ? 1 : 0;
    final relevantCategories = _categoryDataMap.keys.where((key) {
      final type = _categoryDataMap[key]['type'];
      return type == targetType || key == 'Lainnya';
    }).toList();
    return ["Semua", ...relevantCategories];
  }

  DateTime? _parseDateStr(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length != 3) return null;
      return DateTime(
        int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _pickDateRange() async {
    if (_selectedDateRange != null) {
      final shouldReset = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text("Filter Tanggal"),
          content: const Text("Hapus filter tanggal saat ini?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Ganti")),
            TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Hapus Filter", style: TextStyle(color: Colors.red))),
          ],
        ),
      );

      if (shouldReset == true) {
        setState(() => _selectedDateRange = null);
        return;
      }
    }

    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: darkGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final int targetType = _selectedTab == 0 ? 1 : 0;
    final categories = _categoryFilterNames;
    final selectedCategoryName = categories[_selectedCategoryIndex];

    // Filter Data
    final currentList = provider.transactions.where((item) {
      final matchesType = item['type'] == targetType;
      final matchesCategory = selectedCategoryName == "Semua" || item['category'] == selectedCategoryName;
      final matchesSearch = item['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['category'].toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesDate = true;
      if (_selectedDateRange != null) {
        final txDate = _parseDateStr(item['date'] ?? '');
        if (txDate != null) {
          final start = _selectedDateRange!.start;
          final end = _selectedDateRange!.end.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
          matchesDate = txDate.isAfter(start.subtract(const Duration(seconds: 1))) && txDate.isBefore(end);
        } else {
          matchesDate = false;
        }
      }
      return matchesType && matchesCategory && matchesSearch && matchesDate;
    }).toList();

    // --- SORTING: TERBARU DI ATAS ---
    // Karena list `provider.transactions` biasanya urut dari terlama ke terbaru (FIFO di list.add),
    // kita perlu membalik urutannya untuk tampilan LIFO (Stack).
    final reversedList = currentList.reversed.toList(); 

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. HEADER
          Container(
            color: primaryGreen,
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 25),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    const Text(
                      "Riwayat Transaksi",
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: textColor),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 50,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
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
              ),
            ),
          ),

          // 2. KONTEN
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: List.generate(categories.length, (index) {
                      return _buildCategoryChip(categories[index], index);
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                // Search & Calendar
                _buildSearchAndTools(),
                const SizedBox(height: 16),
                
                // List Items (Gunakan reversedList)
                Expanded(
                  child: reversedList.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: reversedList.length,
                          separatorBuilder: (c, i) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final item = reversedList[index]; // Ambil dari list yang sudah dibalik
                            return _buildTransactionItem(item);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER --- (Tidak ada perubahan signifikan di sini)

  Widget _buildTabButton(String text, int index) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
            _selectedCategoryIndex = 0;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
              color: isSelected ? textColor : textColor.withOpacity(0.6),
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
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? darkGreen : const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndTools() {
    bool isDateFilterActive = _selectedDateRange != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              padding: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(fontSize: 14, color: textColor),
                decoration: const InputDecoration(
                  hintText: "Cari transaksi...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  suffixIcon: Icon(Icons.search, color: Colors.grey, size: 24),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _pickDateRange,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDateFilterActive ? darkGreen.withOpacity(0.1) : const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(15),
                border: isDateFilterActive ? Border.all(color: darkGreen) : null,
              ),
              child: Icon(
                isDateFilterActive ? Icons.event_available : Icons.calendar_today_outlined,
                color: isDateFilterActive ? darkGreen : Colors.grey,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> item) {
    bool isExpense = item['type'] == 1;
    final categoryDetails = _getCategoryDetails(item['category']);
    final itemIcon = categoryDetails['icon'] as IconData;
    final itemColor = categoryDetails['color'] as Color;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TransactionDetailScreen(data: item)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
            Container(
              width: 45, height: 45,
              decoration: BoxDecoration(
                color: itemColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(itemIcon, color: itemColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? 'Transaksi',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['category'] ?? 'Umum',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isExpense ? const Color(0xFFFFEBEE) : const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      TransactionProvider.formatRupiah(item['amount'] ?? 0),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isExpense ? const Color(0xFFE53935) : const Color(0xFF2962FF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item['date'] ?? '-', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                const SizedBox(height: 4),
                Text(item['time'] ?? '-', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                const SizedBox(height: 12),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("Belum ada riwayat", style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}