// lib/screens/reminder/billreminder_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Wajib untuk format Rupiah
import 'package:iritin/providers/dashboard_provider.dart';
import 'package:iritin/models/bill_provider.dart';
import 'package:iritin/services/notification_service.dart'; // Import untuk cancel notifikasi
import 'addreminder_screen.dart';

// --- DEFINISI WARNA KUNCI ---
const Color primaryGreen = Color(0xFFD1F333);
const Color accentGreen = Color(0xFFF2FFB0);
const Color textColor = Color(0xFF2E4053);
const Color darkGreen = Color(0xFF558B2F);

class BillReminderScreen extends StatefulWidget {
  const BillReminderScreen({super.key});

  @override
  State<BillReminderScreen> createState() => _BillReminderScreenState();
}

class _BillReminderScreenState extends State<BillReminderScreen> {
  // --- DATA KATEGORI ---
  final Map<String, dynamic> _billCategoryDataMap = {
    'Tagihan': {'icon': Icons.lightbulb, 'color': Colors.brown},
    'Sewa/Cicilan': {'icon': Icons.home, 'color': Colors.indigo},
    'Internet': {'icon': Icons.wifi, 'color': Colors.teal},
    'Pendidikan': {'icon': Icons.school, 'color': Colors.blue},
    'Lainnya': {'icon': Icons.more_horiz, 'color': Colors.grey},
  };

  Map<String, dynamic> _getCategoryDetails(String categoryName) {
    return _billCategoryDataMap[categoryName] ??
        {'icon': Icons.help_outline, 'color': Colors.grey};
  }

  // --- STATE ---
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';
  final int _maxItemsPerPage = 5;
  String _activeTab = 'Upcoming';
  int _currentPage = 1;
  String _selectedCategoryFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    // LOGIKA FIREBASE: Ambil data saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillProvider>().fetchBills();
    });
    _searchController.addListener(_updateSearchQuery);
  }

  @override
  void dispose() {
    _searchController.removeListener(_updateSearchQuery);
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearchQuery() {
    setState(() {
      _currentSearchQuery = _searchController.text.toLowerCase();
      _currentPage = 1;
    });
  }

  // --- FORMATTER RUPIAH ---
  String _formatRupiah(String amount) {
    String cleanAmount = amount.replaceAll(RegExp(r'[^0-9]'), '');
    double value = double.tryParse(cleanAmount) ?? 0;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  // --- LOGIC DATA ---
  List<BillModel> _currentFilteredList(List<BillModel> allBills) {
    return allBills.where((bill) {
      final matchesSearch = bill.name.toLowerCase().contains(
        _currentSearchQuery,
      );
      final matchesTab =
          (_activeTab == 'Upcoming' && bill.status == 'Unpaid Bill') ||
          (_activeTab == 'Paid' && bill.status == 'Paid');
      final matchesCategory =
          _selectedCategoryFilter == 'Semua' ||
          bill.category == _selectedCategoryFilter;
      return matchesSearch && matchesTab && matchesCategory;
    }).toList();
  }

  List<String> _getUniqueCategories(List<BillModel> allBills) {
    final Set<String> categories = {};
    for (var bill in allBills) {
      categories.add(bill.category);
    }
    return ['Semua', ...categories.toList()];
  }

  double _totalAmount(List<BillModel> allBills) {
    return allBills.fold(0.0, (sum, item) {
      final cleanAmount = item.amount.replaceAll('.', '').replaceAll(',', '');
      final amount = double.tryParse(cleanAmount) ?? 0.0;
      return sum + amount;
    });
  }

  int _paidCount(List<BillModel> allBills) =>
      allBills.where((bill) => bill.status == 'Paid').length;
  int _upcomingCount(List<BillModel> allBills) =>
      allBills.where((bill) => bill.status == 'Unpaid Bill').length;

  // --- NAVIGASI ---
  void _goToNextPage() => setState(() => _currentPage++);
  void _goToPreviousPage() {
    if (_currentPage > 1) setState(() => _currentPage--);
  }

  void _navigateToAddReminderScreen() async {
    final newBill = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddReminderScreen()),
    );

    if (newBill != null && newBill is BillModel) {
      // LOGIKA FIREBASE: addBill sekarang bersifat async (simpan ke Cloud)
      context.read<BillProvider>().addBill(newBill);
      setState(() {
        _currentPage = 1;
        _selectedCategoryFilter = 'Semua';
      });
    }
  }

  // --- DIALOG KONFIRMASI BAYAR ---
  void _showMarkPaidConfirmationDialog(BuildContext context, BillModel bill) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: darkGreen,
                  size: 50,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Bayar Tagihan?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tagihan "${bill.name}" akan ditandai LUNAS.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor.withOpacity(0.7)),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentGreen,
                        foregroundColor: textColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // 1. Update Status (FIREBASE)
                        context.read<BillProvider>().markBillAsPaid(bill);

                        // 2. BATALKAN NOTIFIKASI
                        if (bill.notificationId != null) {
                          await NotificationService().cancelNotification(
                            bill.notificationId!,
                          );
                        }

                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${bill.name} LUNAS!')),
                        );
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text('Bayar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildTopHeader() {
    return Container(
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
                "Bill Reminder",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Jangan sampai telat bayar ya!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(
    double totalAmount,
    int paidCount,
    int upcomingCount,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: primaryGreen.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Tagihan (Semua)',
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(totalAmount.toStringAsFixed(0)),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: accentGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${paidCount + upcomingCount} Item',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (paidCount + upcomingCount) == 0
                    ? 0
                    : paidCount / (paidCount + upcomingCount),
                backgroundColor: Colors.grey.shade100,
                valueColor: const AlwaysStoppedAnimation<Color>(primaryGreen),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$paidCount Lunas / $upcomingCount Belum',
                style: TextStyle(
                  fontSize: 11,
                  color: textColor.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildFilterTab(
                      'Upcoming ($upcomingCount)',
                      'Upcoming',
                    ),
                  ),
                  Expanded(child: _buildFilterTab('Paid ($paidCount)', 'Paid')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, String tabName) {
    final isSelected = _activeTab == tabName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = tabName;
          _currentPage = 1;
          _selectedCategoryFilter = 'Semua';
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isSelected ? textColor : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildBillItem(BillModel bill) {
    final isPaid = bill.status == 'Paid';
    final categoryDetails = _getCategoryDetails(bill.category);
    final itemIcon = categoryDetails['icon'] as IconData;
    final itemColor = categoryDetails['color'] as Color;
    String displayDate = bill.dueDate.split(" ")[0];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: itemColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(itemIcon, color: itemColor, size: 24),
        ),
        title: Text(
          bill.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              bill.category,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Flexible(
                  child: Text(
                    _formatRupiah(bill.amount),
                    style: const TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (!isPaid)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Due: $displayDate',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: isPaid
            ? const Icon(Icons.check_circle, color: primaryGreen, size: 28)
            : ElevatedButton(
                onPressed: () => _showMarkPaidConfirmationDialog(context, bill),
                style: ElevatedButton.styleFrom(
                  backgroundColor: textColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  minimumSize: const Size(60, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Bayar', style: TextStyle(fontSize: 12)),
              ),
      ),
    );
  }

  Widget _buildSearchBar(List<BillModel> allBills) {
    final categories = _getUniqueCategories(allBills);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _searchController,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Cari tagihan...',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: primaryGreen),
            ),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 15,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              final isSelected = _selectedCategoryFilter == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: primaryGreen,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? primaryGreen : Colors.grey.shade200,
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? textColor : Colors.grey,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategoryFilter = category;
                      _currentPage = 1;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final billProvider = context.watch<BillProvider>();
    final allBills = billProvider.allBills;

    final currentFilteredList = _currentFilteredList(allBills);
    final totalFilteredItems = currentFilteredList.length;
    final totalAmount = _totalAmount(allBills);
    final paidCount = _paidCount(allBills);
    final upcomingCount = _upcomingCount(allBills);

    final startIndex = (_currentPage - 1) * _maxItemsPerPage;
    final endIndex = (_currentPage * _maxItemsPerPage).clamp(
      0,
      totalFilteredItems,
    );
    final paginatedItems = currentFilteredList.sublist(startIndex, endIndex);

    final isLastPage = endIndex >= totalFilteredItems;
    final isFirstPage = _currentPage == 1;
    final bool isUserNew = allBills.isEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildTopHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (isUserNew) ...[
                    Card(
                      color: accentGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.receipt_long,
                              size: 60,
                              color: darkGreen,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Belum Ada Tagihan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tekan tombol + untuk menambah tagihan',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    _buildSummaryHeader(totalAmount, paidCount, upcomingCount),
                    const SizedBox(height: 24),
                    _buildSearchBar(allBills),
                    const SizedBox(height: 20),
                    if (paginatedItems.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            "Tidak ada tagihan ditemukan.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: paginatedItems
                            .map((bill) => _buildBillItem(bill))
                            .toList(),
                      ),
                    if (totalFilteredItems > _maxItemsPerPage)
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 100,
                              child: isFirstPage
                                  ? const SizedBox()
                                  : TextButton(
                                      onPressed: _goToPreviousPage,
                                      child: const Text(
                                        '< Prev',
                                        style: TextStyle(
                                          color: darkGreen,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ),
                            Text(
                              'Halaman $_currentPage',
                              style: TextStyle(
                                color: textColor.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: isLastPage
                                  ? const SizedBox()
                                  : TextButton(
                                      onPressed: _goToNextPage,
                                      child: const Text(
                                        'Next >',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          color: darkGreen,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 50),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddReminderScreen,
        backgroundColor: primaryGreen,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: textColor, size: 30),
      ),
    );
  }
}
