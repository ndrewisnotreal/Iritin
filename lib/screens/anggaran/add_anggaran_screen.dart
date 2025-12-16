import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'all_anggaran_screen.dart'; // Import untuk navigasi ke daftar

// --- ASUMSI WARNA ---
const Color primaryGreen = Color(0xFFD1F333); 
const Color accentGreen = Color(0xFFF2FFB0); 
const Color textColor = Color(0xFF2E4053); 
const Color darkGreen = Color(0xFF558B2F); 
// --------------------

// Model untuk menampung data kategori
class CategoryItem {
  final String name;
  final IconData icon;
  final Color color;

  CategoryItem({required this.name, required this.icon, required this.color});
}

// FIX: Nama kelas adalah AddAnggaranScreen
class AddAnggaranScreen extends StatefulWidget {
  const AddAnggaranScreen({super.key});

  @override
  State<AddAnggaranScreen> createState() => _AddAnggaranScreenState();
}

class _AddAnggaranScreenState extends State<AddAnggaranScreen> {
  
  // State untuk Dropdown
  CategoryItem? _selectedCategory;
  String? _selectedMonth;
  
  final TextEditingController _amountController = TextEditingController();

  // Data Kategori Pengeluaran
  final List<CategoryItem> _expenseCategories = [
    CategoryItem(name: 'Pendidikan', icon: Icons.school, color: Colors.blue),
    CategoryItem(name: 'Makanan', icon: Icons.restaurant, color: Colors.red),
    CategoryItem(name: 'Fashion', icon: Icons.checkroom, color: Colors.pink),
    CategoryItem(name: 'Hiburan', icon: Icons.sports_esports, color: Colors.purple),
    CategoryItem(name: 'Transportasi', icon: Icons.directions_bus, color: Colors.orange),
    CategoryItem(name: 'Tagihan', icon: Icons.lightbulb, color: Colors.brown),
    CategoryItem(name: 'Lainnya', icon: Icons.more_horiz, color: Colors.grey),
  ];

  final List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _expenseCategories.first;
    _selectedMonth = _months[DateTime.now().month - 1]; 
  }

  void _submitBudget() {
    if (_amountController.text.isEmpty || _selectedCategory == null || _selectedMonth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field harus diisi.")),
      );
      return;
    }
    
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Icon Success (Check Mark)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: textColor, size: 40),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Anggaran Berhasil Disimpan!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              // Subtitle
              const Text(
                'Anggaran Anda sudah tersimpan. Selamat mengatur keuangan!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: textColor),
              ),
              const SizedBox(height: 30),
              // Tombol "Periksa Anggaran"
              ElevatedButton(
                onPressed: () {
                  // Tutup dialog, tutup form input, navigasi ke daftar overview
                  Navigator.of(context).pop(); 
                  Navigator.of(context).pop(); 
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllAnggaranScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: textColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  'Periksa Anggaran',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              // Tombol "Tutup"
              TextButton(
                onPressed: () {
                  // Tutup dialog, tutup form input
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); 
                },
                child: const Text(
                  'Tutup',
                  style: TextStyle(color: darkGreen),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGETS ---

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryGreen, 
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Tombol Back
          Positioned(
            left: 0,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            ),
          ),
          
          // Ikon Uang Kertas Kustom
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 50,
                width: 90,
                decoration: BoxDecoration(
                  color: darkGreen, 
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ]
                ),
                child: const Center(
                  child: Icon(
                    Icons.attach_money,
                    color: primaryGreen, 
                    size: 30,
                  ),
                ),
              ), 
              const SizedBox(height: 10),
              const Text(
                "Buat Anggaran Baru", // Judul Halaman Form
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          
          // Teks Anggaran Per Bulan dengan Garis Bawah
          Center(
            child: Container(
              padding: const EdgeInsets.only(bottom: 5), 
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: textColor, 
                    width: 2.0,       
                  ),
                ),
              ),
              child: const Text(
                "Anggaran Per Bulan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
          ),
          
          const SizedBox(height: 30),

          _buildFormLabel('Kategori'),
          _buildCategoryDropdown(),
          const SizedBox(height: 20),

          _buildFormLabel('Bulan'),
          _buildMonthDropdown(),
          const SizedBox(height: 20),

          _buildFormLabel('Jumlah Anggaran'),
          _buildAmountInput(),
          const SizedBox(height: 40),

          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    );
  }
  
  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: accentGreen,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primaryGreen),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CategoryItem>(
          isExpanded: true,
          value: _selectedCategory,
          hint: const Text("Pilih Kategori"),
          icon: const Icon(Icons.keyboard_arrow_down, color: darkGreen),
          items: _expenseCategories.map((CategoryItem category) {
            return DropdownMenuItem<CategoryItem>(
              value: category,
              child: Row(
                children: [
                  Icon(category.icon, color: darkGreen), 
                  const SizedBox(width: 12),
                  Text(category.name, style: const TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }).toList(),
          onChanged: (CategoryItem? newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildMonthDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: accentGreen,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primaryGreen),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedMonth,
          hint: const Text("Pilih Bulan"),
          icon: const Icon(Icons.keyboard_arrow_down, color: darkGreen),
          items: _months.map((String month) {
            return DropdownMenuItem<String>(
              value: month,
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: darkGreen, size: 20),
                  const SizedBox(width: 12),
                  Text(month, style: const TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedMonth = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    final formatter = NumberFormat('#,###', 'id_ID');

    return Container(
      decoration: BoxDecoration(
        color: accentGreen,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primaryGreen),
      ),
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: Text('Rp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          hintText: formatter.format(1000000), 
          hintStyle: TextStyle(color: textColor.withOpacity(0.5), fontWeight: FontWeight.bold),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Tombol Batal
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
            child: const Text("Batal", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        // Tombol Simpan
        Expanded(
          child: ElevatedButton(
            onPressed: _submitBudget,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen, 
              foregroundColor: textColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 3,
            ),
            child: const Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 30),
            _buildForm(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}