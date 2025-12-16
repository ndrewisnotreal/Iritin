import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'addreminder_screen.dart'; 
import 'package:iritin/providers/dashboard_provider.dart'; 

// FIX KONFLIK 1: Import BillModel dari file model yang benar
import 'package:iritin/models/bill_model.dart'; 
// FIX KONFLIK 2: Sembunyikan BillModel dari provider (hanya jaga-jaga)
import 'package:iritin/providers/bill_provider.dart' hide BillModel; 

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
    final details = _billCategoryDataMap[categoryName];
    if (details != null) return details;
    return _billCategoryDataMap['Lainnya'] ?? {'icon': Icons.help_outline, 'color': Colors.grey};
  }
  
  // --- STATE PAGINASI DAN FILTER ---
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';
  final int _maxItemsPerPage = 5; 
  String _activeTab = 'Upcoming'; 
  int _currentPage = 1; 
  String _selectedCategoryFilter = 'Semua'; 
  
  @override
  void initState() {
    super.initState();
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
  
  void _goToNextPage() { setState(() { _currentPage++; }); }
  void _goToPreviousPage() { if (_currentPage > 1) setState(() { _currentPage--; }); }

  void _navigateToDashboardIndex(BuildContext context, int index) {
      context.read<DashboardProvider>().setIndex(index);
  }

  void _navigateToAddReminderScreen() async {
    final newBill = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddReminderScreen()),
    );

    if (newBill != null && newBill is BillModel) {
      context.read<BillProvider>().addBill(newBill); 
      setState(() {
        _currentPage = 1; 
        _selectedCategoryFilter = 'Semua'; 
      });
    }
  }

  List<BillModel> _currentFilteredList(List<BillModel> allBills) { 
      return allBills.where((bill) {
        final matchesSearch = bill.name.toLowerCase().contains(_currentSearchQuery);
        final matchesTab = (_activeTab == 'Upcoming' && bill.status == 'Unpaid Bill') ||
                           (_activeTab == 'Paid' && bill.status == 'Paid');
        final matchesCategory = _selectedCategoryFilter == 'Semua' || bill.category == _selectedCategoryFilter;
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
      final amount = double.tryParse(item.amount.replaceAll('.', '').replaceAll(',', '')) ?? 0.0;
      return sum + amount;
    });
  }
  
  int _paidCount(List<BillModel> allBills) => allBills.where((bill) => bill.status == 'Paid').length;
  int _upcomingCount(List<BillModel> allBills) => allBills.where((bill) => bill.status == 'Unpaid Bill').length;

  void _showMarkPaidConfirmationDialog(BuildContext context, BillModel bill) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: primaryGreen.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_outline, color: darkGreen, size: 50),
                ),
                const SizedBox(height: 15),
                const Text('Tandai Sudah Dibayar?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 10),
                Text('Tagihan "${bill.name}" akan ditandai sebagai LUNAS. Lanjutkan?', textAlign: TextAlign.center, style: TextStyle(color: textColor.withOpacity(0.7))),
                const SizedBox(height: 30),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(), 
                        style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: textColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12)),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<BillProvider>().markBillAsPaid(bill); 
                          Navigator.of(dialogContext).pop(); 
                          
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${bill.name} berhasil ditandai LUNAS!')));
                          setState(() {}); 
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: darkGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 3, padding: const EdgeInsets.symmetric(vertical: 12)),
                        child: const Text('Bayar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            contentPadding: const EdgeInsets.all(20),
          );
        },
      );
  }

  Widget _buildCustomHeader(String userName, String avatarUrl) {
    return AppBar(automaticallyImplyLeading: false, backgroundColor: Colors.transparent, flexibleSpace: ClipPath(clipper: _SimpleCurveClipper(), child: Container(height: 150, color: primaryGreen, child: Padding(padding: const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [const CircleAvatar(radius: 25, backgroundImage: AssetImage('assets/avatar.jpg'), backgroundColor: Colors.white), const SizedBox(width: 15), Text('Halo, $userName!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor))]), const SizedBox.shrink()])))));
  }
  
  Widget _buildBillReminderCard() {
    return Card(color: accentGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)), elevation: 5, child: Padding(padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0), child: Column(children: [Text('BILL REMINDER', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor, letterSpacing: 1.5)), const SizedBox(height: 25), Image.asset('assets/logo.jpg', height: 200, width: 200), const SizedBox(height: 25), Text('Belum Ada Tagihan yang Disimpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor))])));
  }
  
  Widget _buildSuggestionBubble() {
    return Container(padding: const EdgeInsets.all(20.0), decoration: BoxDecoration(color: accentGreen, borderRadius: BorderRadius.circular(30.0), border: Border.all(color: primaryGreen, width: 2)), child: const Text('Yuk tambahkan pengingat tagihan pertamamu supaya tidak lupa membayar tagihan tepat waktu', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)));
  }

  Widget _buildSummaryHeader(double totalAmount, int paidCount, int upcomingCount) {
    String formattedTotal = totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return Card(color: primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)), elevation: 5, child: Padding(padding: const EdgeInsets.all(20.0), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('BILL REMINDER', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)), const SizedBox(height: 15), Text('Total Tagihan Bulan Ini', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: textColor)), Text('Rp ${formattedTotal}', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: textColor)), const SizedBox(height: 10), ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: (paidCount + upcomingCount) == 0 ? 0 : paidCount / (paidCount + upcomingCount), backgroundColor: accentGreen, valueColor: AlwaysStoppedAnimation<Color>(darkGreen), minHeight: 10)), const SizedBox(height: 5), Text('$paidCount dari ${paidCount + upcomingCount} tagihan sudah dibayar', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: textColor)), const SizedBox(height: 15), Row(mainAxisAlignment: MainAxisAlignment.center, children: [Expanded(child: _buildFilterTab('Upcoming ($upcomingCount)', 'Upcoming', -1)), const SizedBox(width: 10), Expanded(child: _buildFilterTab('Paid ($paidCount)', 'Paid', -1)), const SizedBox(width: 15), Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: accentGreen, borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.calendar_month, color: textColor))])])));
  }

  Widget _buildFilterTab(String label, String tabName, int targetIndex) {
    final isSelected = _activeTab == tabName;
    return ElevatedButton(onPressed: () { if (targetIndex == 0 || targetIndex == 1) { _navigateToDashboardIndex(context, targetIndex); return; } setState(() { _activeTab = tabName; _currentPage = 1; _selectedCategoryFilter = 'Semua'; }); }, style: ElevatedButton.styleFrom(backgroundColor: isSelected ? darkGreen : accentGreen, foregroundColor: isSelected ? Colors.white : textColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: isSelected ? 3 : 0, padding: const EdgeInsets.symmetric(vertical: 12)), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)));
  }

  Widget _buildSearchBar(List<BillModel> allBills) {
    final categories = _getUniqueCategories(allBills);
    
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextFormField(controller: _searchController, style: TextStyle(color: textColor), decoration: InputDecoration(hintText: 'Search bill reminder...', hintStyle: TextStyle(color: textColor.withOpacity(0.5)), filled: true, fillColor: accentGreen, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none), prefixIcon: Icon(Icons.search, color: darkGreen), contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15), suffixIcon: Icon(Icons.keyboard_arrow_down, color: darkGreen))),
        const SizedBox(height: 15),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: categories.map((category) { final isSelected = _selectedCategoryFilter == category; return Padding(padding: const EdgeInsets.only(right: 10), child: ChoiceChip(label: Text(category), selected: isSelected, selectedColor: darkGreen, backgroundColor: accentGreen, labelStyle: TextStyle(color: isSelected ? Colors.white : darkGreen, fontWeight: FontWeight.bold), onSelected: (selected) { setState(() { _selectedCategoryFilter = category; _currentPage = 1; }); })); }).toList())),
    ]);
  }
  
  Widget _buildBillItem(BillModel bill) {
    final isPaid = bill.status == 'Paid';
    final categoryDetails = _getCategoryDetails(bill.category); 
    final itemIcon = categoryDetails['icon'] as IconData;
    final itemColor = categoryDetails['color'] as Color;

    return Card(margin: const EdgeInsets.only(bottom: 15), color: accentGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 2, child: ListTile(leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: itemColor.withOpacity(0.8), borderRadius: BorderRadius.circular(10)), child: Icon(itemIcon, color: Colors.white)), title: Text(bill.name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text('Kategori: ${bill.category}', style: TextStyle(color: textColor.withOpacity(0.7))), Text('Rp. ${bill.amount}', style: TextStyle(color: textColor.withOpacity(0.9), fontWeight: FontWeight.w600)), if (!isPaid) Text('Due: ${bill.dueDate}', style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600))]), trailing: isPaid ? Padding(padding: const EdgeInsets.only(right: 8.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.check_circle, color: darkGreen), Text(bill.status, style: TextStyle(color: darkGreen, fontSize: 12, fontWeight: FontWeight.w600))])) : SizedBox(width: 80, child: ElevatedButton(onPressed: () => _showMarkPaidConfirmationDialog(context, bill), style: ElevatedButton.styleFrom(backgroundColor: darkGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8)), child: const Text('Bayar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))))));
  }

  Widget _buildPaginationControls(bool isFirst, bool isLast, int totalItems, int limit) {
    return Padding(padding: const EdgeInsets.only(top: 15.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [SizedBox(width: 100, child: isFirst ? const SizedBox() : TextButton(onPressed: _goToPreviousPage, child: Text('< Prev', style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold)))), Text('Halaman $_currentPage', style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14)), SizedBox(width: 100, child: isLast ? const SizedBox() : TextButton(onPressed: _goToNextPage, child: Text('Next >', textAlign: TextAlign.end, style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold))))]));
  }
  
  @override
  Widget build(BuildContext context) {
    final billProvider = context.watch<BillProvider>();
    final List<BillModel> allBills = billProvider.allBills.cast<BillModel>();

    final currentFilteredList = _currentFilteredList(allBills);
    final totalFilteredItems = currentFilteredList.length;
    final totalAmount = _totalAmount(allBills);
    final paidCount = _paidCount(allBills);
    final upcomingCount = _upcomingCount(allBills);
    
    final startIndex = (_currentPage - 1) * _maxItemsPerPage;
    final endIndex = (_currentPage * _maxItemsPerPage).clamp(0, totalFilteredItems);
    
    final paginatedItems = (startIndex < totalFilteredItems) 
        ? currentFilteredList.sublist(startIndex, endIndex) 
        : <BillModel>[];
    
    final isLastPage = endIndex >= totalFilteredItems;
    final isFirstPage = _currentPage == 1;
    final bool isUserNew = allBills.isEmpty; 
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: _buildCustomHeader('Wildan Adzkia', 'assets/avatar.jpg'),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            
            if (isUserNew) ...[
              _buildBillReminderCard(), 
              const SizedBox(height: 30),
              _buildSuggestionBubble(),
            ] 
            
            else ...[
              
              _buildSummaryHeader(totalAmount, paidCount, upcomingCount),
              const SizedBox(height: 20),
              
              _buildSearchBar(allBills), 
              const SizedBox(height: 20),
              
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text('${_activeTab.toUpperCase()} REMINDERS:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
              ),
              
              if (paginatedItems.isEmpty)
                 Center(child: Text("Tidak ada tagihan yang cocok di tab ini.", style: TextStyle(color: textColor)))
              else
                Column(
                  children: paginatedItems.map((bill) => _buildBillItem(bill)).toList(),
                ),
              
              if (totalFilteredItems > _maxItemsPerPage)
                _buildPaginationControls(isFirstPage, isLastPage, totalFilteredItems, _maxItemsPerPage),
              
              const SizedBox(height: 50),
            ]
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddReminderScreen,
        backgroundColor: primaryGreen, 
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

class _SimpleCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 20);
    var controlPoint = Offset(size.width / 2, size.height + 20);
    var endPoint = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(_SimpleCurveClipper oldClipper) => false;
}