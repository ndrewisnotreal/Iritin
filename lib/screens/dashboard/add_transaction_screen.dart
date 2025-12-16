import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:iritin/providers/transaction_provider.dart'; 
import 'package:iritin/providers/account_provider.dart';
import 'package:iritin/providers/account_provider.dart' show AccountModel; 
import 'package:iritin/styling/app_colors.dart';
import 'dart:ui'; // Import untuk BackdropFilter
// Asumsi AddAccountScreen ada di folder screens/dashboard
import 'package:iritin/screens/dashboard/add_account_screen.dart';
// Import AccountsScreen untuk navigasi
import 'package:iritin/screens/dashboard/accounts_screen.dart'; 


// --- WARNA DARI BILL REMINDER STYLE UNTUK KONSISTENSI DIALOG ---
const Color textColor = Color(0xFF2E4053); 
const Color darkGreen = Color(0xFF558B2F); 
// -------------------------------------------------------------

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
  
  CategoryItem? _selectedCategory;
  AccountModel? _selectedAccount; 


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
  
  final List<CategoryItem> _incomeCategories = [
    CategoryItem(name: 'Upah', icon: Icons.payments, color: Colors.green.shade700),
    CategoryItem(name: 'Bisnis', icon: Icons.store, color: Colors.teal),
    CategoryItem(name: 'Bunga', icon: Icons.trending_up, color: Colors.indigo),
    CategoryItem(name: 'Insentif', icon: Icons.star, color: Colors.amber),
    CategoryItem(name: 'Lainnya', icon: Icons.more_horiz, color: Colors.grey),
  ];

  List<CategoryItem> get _currentCategories {
    return _transactionType == 1 ? _expenseCategories : _incomeCategories;
  }
  
  @override
  void initState() {
    super.initState();
    _selectedCategory = _expenseCategories.first;
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final accountProvider = context.read<AccountProvider>();
    if (accountProvider.accounts.isNotEmpty && _selectedAccount == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedAccount = accountProvider.accounts.first;
        });
      });
    }
  }

  void _setTransactionType(int newType) {
    if (_transactionType != newType) {
      setState(() {
        _transactionType = newType;
        _selectedCategory = _currentCategories.first;
      });
    }
  }

  void _addTransactionToProvider() {
    final transactionProvider = context.read<TransactionProvider>();
    final accountProvider = context.read<AccountProvider>();

    // 1. Validasi Input (Termasuk Deskripsi Wajib)
    if (_amountController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Jumlah dan Kategori harus diisi!")),
      );
      return;
    }
    
    // FIX: Validasi Deskripsi Wajib Diisi
    if (_descController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Harap mengisi deskripsi transaksi!"),
                backgroundColor: Colors.red,
            ),
        );
        return;
    }
    
    // 1.1 Validasi Akun
    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih akun rekening!")),
      );
      return;
    }

    // 2. Parse Data
    final rawAmountText = _amountController.text.replaceAll(RegExp(r'[Rp\.]'), '').replaceAll(',', '').trim();
    final double amountValue = double.tryParse(rawAmountText) ?? 0.0;
    
    if (amountValue <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Jumlah nominal harus lebih dari nol.")),
        );
        return;
    }
    
    final int amountInt = amountValue.toInt();
    final String categoryName = _selectedCategory!.name;
    final String desc = _descController.text;
    
    // 3. Update Saldo Akun yang Dipilih
    double amountToUpdate = (_transactionType == 1) ? -amountValue : amountValue;
    
    try {
        accountProvider.updateAccountBalance(
            _selectedAccount!.id, 
            amountToUpdate,
        );
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error update saldo: $e")),
        );
        print("RUNTIME ERROR PADA UPDATE SALDO: $e");
        return; 
    }

    // 4. SIMPAN Transaksi ke TransactionProvider (Map-based call)
    transactionProvider.addTransaction(
      type: _transactionType,
      amount: amountInt,
      category: categoryName,
      desc: desc,
    );

    // 5. Tutup Halaman
    Navigator.pop(context);
  }
  
  // WIDGET KONFIRMASI (FIXED STYLING & NO YELLOW LINES)
  Widget _buildAccountPrompt(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Efek Blur
      child: Container(
        color: Colors.black.withOpacity(0.4), // Overlay Gelap
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ikon Warning Merah
                const Icon(
                  Icons.warning_rounded, 
                  size: 50,
                  color: Colors.red, 
                ),
                const SizedBox(height: 16),
                // FIX: Text Judul (Eksplisit TextStyle)
                const Text(
                  "Tambahkan rekening Anda",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor), 
                ),
                const SizedBox(height: 8),
                // FIX: Text Badan Pesan (Eksplisit TextStyle)
                Text(
                  "Tambahkan rekening Anda untuk mulai mengelola dan memantau pengeluaran secara lebih teratur.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14), 
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    // Tombol KEMBALI (Style Sekunder)
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200, 
                          foregroundColor: textColor, // FIX: Font color textColor
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          // Navigasi kembali ke home
                          Navigator.pop(context); 
                        },
                        // FIX: Memastikan font hitam (textColor)
                        child: const Text("Kembali", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tombol TAMBAH REKENING (Style Primer/darkGreen)
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkGreen, // FIX: Menggunakan darkGreen
                          foregroundColor: Colors.white, // FIX: Font color Putih
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          // Navigasi ke AddAccountScreen dan tunggu hasilnya
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddAccountScreen()), 
                          );
                          
                          // FIX NAVIGASI: Setelah AddAccount selesai, arahkan ke AccountsScreen
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const AccountsScreen()),
                            );
                          }
                        },
                        // FIX: Memastikan font putih
                        child: const Text("Tambah Rekening", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final hasAccounts = accountProvider.accounts.isNotEmpty;

    // Menumpuk widget Konfirmasi di atas formulir jika tidak ada akun
    return Stack(
      children: [
        // Widget Formulir Utama
        Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
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
                          
                          // FIX: Deskripsi Paling Atas
                          _buildInputLabel("Deskripsi"),
                          _buildTextField(
                            controller: _descController,
                            hint: "Detail transaksi...",
                            icon: Icons.notes,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),

                          _buildInputLabel("Jumlah Nominal"),
                          _buildTextField(
                            controller: _amountController,
                            hint: "Rp0",
                            keyboardType: TextInputType.number,
                            icon: Icons.attach_money,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildInputLabel("Kategori Transaksi"),
                          _buildCategoryDropdown(),
                          const SizedBox(height: 16),
                          
                          _buildInputLabel("Akun Rekening"),
                          _buildAccountDropdown(hasAccounts, accountProvider.accounts),
                          const SizedBox(height: 32),
                          
                          _buildActionButtons(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Menampilkan Konfirmasi di atas seluruh layar jika tidak ada akun
        if (!hasAccounts)
          Positioned.fill(
            child: _buildAccountPrompt(context),
          ),
      ],
    );
  }
  
  // WIDGET BARU: Dropdown Akun Rekening
  Widget _buildAccountDropdown(bool hasAccounts, List<AccountModel> accounts) {
    if (!hasAccounts) {
      return const SizedBox(); 
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AccountModel>(
          isExpanded: true,
          value: _selectedAccount,
          hint: const Text("Pilih Akun Rekening"),
          icon: const Icon(Icons.account_balance_wallet, color: Colors.grey),
          items: accounts.map((AccountModel account) {
            return DropdownMenuItem<AccountModel>(
              value: account,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: account.colors.isNotEmpty ? account.colors[0] : Colors.blue.shade700, 
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.credit_card, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(account.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Saldo: ${account.saldo}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (AccountModel? newValue) {
            setState(() {
              _selectedAccount = newValue;
            });
          },
        ),
      ),
    );
  }


  // WIDGET DROPDOWN KATEGORI
  Widget _buildCategoryDropdown() {
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
          value: _selectedCategory, 
          hint: const Text("Pilih Kategori"),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: _currentCategories.map((CategoryItem category) {
            return DropdownMenuItem<CategoryItem>(
              value: category,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: category.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(category.icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
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