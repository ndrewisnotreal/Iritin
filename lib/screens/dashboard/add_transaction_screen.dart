import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:iritin/providers/transaction_provider.dart'; 
import 'package:iritin/styling/app_colors.dart';

// Model untuk menampung data kategori dan ikonnya
class CategoryItem {
  final String name;
  final IconData icon;
  final Color color;

  CategoryItem({required this.name, required this.icon, required this.color});
}

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  
  // 0 = Pemasukan, 1 = Pengeluaran
  int _transactionType = 1;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  // State untuk Dropdown yang dipilih
  CategoryItem? _selectedCategory;

  // --- DEFINISI KATEGORI ---

  final List<CategoryItem> _expenseCategories = [
    CategoryItem(name: 'Pendidikan', icon: Icons.school, color: Colors.blue),
    CategoryItem(name: 'Makanan', icon: Icons.restaurant, color: Colors.red),
    CategoryItem(name: 'Fashion', icon: Icons.checkroom, color: Colors.pink),
    CategoryItem(name: 'Hiburan', icon: Icons.sports_esports, color: Colors.purple),
    CategoryItem(name: 'Transportasi', icon: Icons.directions_bus, color: Colors.orange),
    CategoryItem(name: 'Tagihan', icon: Icons.lightbulb, color: Colors.brown),
    CategoryItem(name: 'Lainnya', icon: Icons.more_horiz, color: Colors.grey),
  ];
  
  // BARU: Data Kategori Pemasukan
  final List<CategoryItem> _incomeCategories = [
    CategoryItem(name: 'Upah', icon: Icons.payments, color: Colors.green.shade700),
    CategoryItem(name: 'Bisnis', icon: Icons.store, color: Colors.teal),
    CategoryItem(name: 'Bunga', icon: Icons.trending_up, color: Colors.indigo),
    CategoryItem(name: 'Insentif', icon: Icons.star, color: Colors.amber),
    CategoryItem(name: 'Lainnya', icon: Icons.more_horiz, color: Colors.grey),
  ];

  // Getter yang memilih List kategori berdasarkan tipe transaksi
  List<CategoryItem> get _currentCategories {
    return _transactionType == 1 ? _expenseCategories : _incomeCategories;
  }
  
  @override
  void initState() {
    super.initState();
    // Set kategori default ke item pertama saat inisialisasi (Pengeluaran)
    _selectedCategory = _expenseCategories.first;
  }
  
  // Override setState untuk reset kategori saat tipe transaksi diubah
  void _setTransactionType(int newType) {
    if (_transactionType != newType) {
      setState(() {
        _transactionType = newType;
        // Reset kategori yang dipilih agar sesuai dengan tipe yang baru
        _selectedCategory = _currentCategories.first;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER
            _buildHeader(context),

            // 2. FORM BODY
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "DETAILS",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildTypeToggle(),
                      const SizedBox(height: 24),

                      _buildInputLabel("Jumlah Nominal"),
                      _buildTextField(
                        controller: _amountController,
                        hint: "Rp0",
                        keyboardType: TextInputType.number,
                        icon: Icons.attach_money,
                      ),
                      const SizedBox(height: 16),

                      _buildInputLabel("Kategori Transaksi"),
                      // Dropdown Kategori
                      _buildCategoryDropdown(),
                      const SizedBox(height: 16),

                      _buildInputLabel("Deskripsi"),
                      _buildTextField(
                        controller: _descController,
                        hint: "Detail transaksi...",
                        icon: Icons.notes,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),

                      // Tombol Action
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET DROPDOWN BARU
  Widget _buildCategoryDropdown() {
    // Pastikan _currentCategories tidak kosong sebelum membangun Dropdown
    if (_currentCategories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text("Tidak ada kategori tersedia."),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CategoryItem>(
          isExpanded: true,
          // Value harus ada dalam list items saat ini
          value: _selectedCategory, 
          hint: const Text("Pilih Kategori"),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: _currentCategories.map((CategoryItem category) {
            return DropdownMenuItem<CategoryItem>(
              value: category,
              child: Row(
                children: [
                  // Ikon Kategori
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: category.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(category.icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  // Nama Kategori
                  Text(category.name, style: const TextStyle(fontWeight: FontWeight.w600)),
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


  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 60),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=11',
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Halo,",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    "Wildan Adzkia!",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // FIX: Memanggil _setTransactionType
          _buildToggleOption("Pemasukan", 0, Colors.blue),
          _buildToggleOption("Pengeluaran", 1, Colors.red),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String text, int index, Color activeColor) {
    bool isSelected = _transactionType == index;
    return Expanded(
      child: GestureDetector(
        // FIX: Memanggil fungsi setter baru
        onTap: () => _setTransactionType(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected) ...[
                Icon(
                  index == 0 ? Icons.arrow_downward : Icons.arrow_upward,
                  size: 16,
                  color: activeColor,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? activeColor : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  void _addTransactionToProvider() {
    // 1. Validasi Input
    if (_amountController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Jumlah dan Kategori harus diisi!")),
      );
      return;
    }

    // 2. Parse Data
    int amount = int.tryParse(_amountController.text) ?? 0;
    String categoryName = _selectedCategory!.name;
    String desc = _descController.text;

    // 3. SIMPAN KE PROVIDER
    context.read<TransactionProvider>().addTransaction(
      type: _transactionType,
      amount: amount,
      category: categoryName,
      desc: desc,
      // Catatan: Pastikan model transaksi di provider Anda mendukung penyimpanan ikon/warna jika diperlukan di halaman detail
    );

    // 4. Tutup Halaman
    Navigator.pop(context);
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // TOMBOL SIMPAN
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              elevation: 5,
              shadowColor: AppColors.primary.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _addTransactionToProvider,
            child: const Text(
              "Transaksi Baru",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // TOMBOL BATAL
        SizedBox(
          width: double.infinity,
          height: 55,
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Batalkan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}