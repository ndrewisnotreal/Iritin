import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iritin/providers/transaction_provider.dart';
import 'package:iritin/models/account_provider.dart'; // Wajib Import
import 'package:iritin/models/account_provider.dart' show AccountModel;
import 'package:iritin/styling/app_colors.dart';
import 'dart:ui'; // Untuk efek blur
import 'package:iritin/screens/dashboard/add_account_screen.dart';
import 'package:iritin/screens/dashboard/accounts_screen.dart';

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
  int _transactionType = 1; // 0 = Pemasukan, 1 = Pengeluaran
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  CategoryItem? _selectedCategory;
  AccountModel? _selectedAccount; 

  // --- DATA KATEGORI ---
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

  List<CategoryItem> get _currentCategories => _transactionType == 1 ? _expenseCategories : _incomeCategories;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _expenseCategories.first;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final accountProvider = context.read<AccountProvider>();
    
    // Cek otomatis saat halaman dibuka: Apakah User punya rekening?
    if (accountProvider.accounts.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNoAccountDialog();
      });
    } else if (_selectedAccount == null) {
      // Auto-select rekening pertama jika belum ada yg dipilih
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

  // --- POP-UP DIALOG (NAVIGASI DIPERBAIKI) ---
  void _showNoAccountDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_rounded, size: 50, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    "Tambahkan rekening Anda",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E4053)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Anda perlu memiliki minimal satu rekening untuk mencatat transaksi.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      // TOMBOL KEMBALI (FIXED: Close Dialog & Screen)
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(context); // Tutup Dialog
                            Navigator.pop(context); // Tutup Halaman Add Transaction
                          },
                          child: const Text("Kembali"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // TOMBOL TAMBAH (FIXED: Redirect ke AddAccount)
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF558B2F),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(context); // Tutup dialog
                            // Ganti halaman transaksi dengan halaman tambah akun
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const AddAccountScreen()),
                            );
                          },
                          child: const Text("Tambah"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- LOGIKA SIMPAN UTAMA ---
  void _addTransactionToProvider() {
    if (_amountController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Jumlah dan Kategori harus diisi!")),
      );
      return;
    }

    if (_selectedAccount == null) {
      _showNoAccountDialog();
      return;
    }

    String cleanAmount = _amountController.text.replaceAll('.', '').replaceAll(',', '');
    int amount = int.tryParse(cleanAmount) ?? 0;
    if (amount <= 0) return;

    // 1. UPDATE SALDO DI ACCOUNT PROVIDER
    double amountDouble = amount.toDouble();
    // Kalau Pengeluaran (1) -> Negatif, Pemasukan (0) -> Positif
    double balanceChange = (_transactionType == 1) ? -amountDouble : amountDouble;

    context.read<AccountProvider>().updateAccountBalance(
      _selectedAccount!.id,
      balanceChange
    );

    // 2. SIMPAN TRANSAKSI DI TRANSACTION PROVIDER
    context.read<TransactionProvider>().addTransaction(
      type: _transactionType,
      amount: amount,
      category: _selectedCategory!.name,
      desc: _descController.text,
      account: _selectedAccount!.title, // Kirim Nama Rekening
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Transform.translate(
              offset: const Offset(0, -20),
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
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "DETAIL TRANSAKSI",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
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
                      _buildCategoryDropdown(),
                      const SizedBox(height: 16),

                      // DROPDOWN REKENING
                      _buildInputLabel("Pilih Rekening"),
                      _buildAccountDropdown(accountProvider.accounts),
                      const SizedBox(height: 16),

                      _buildInputLabel("Deskripsi"),
                      _buildTextField(
                        controller: _descController,
                        hint: "Contoh: Beli Makan Siang",
                        icon: Icons.notes,
                        maxLines: 1,
                      ),
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
    );
  }

  // --- WIDGET DROPDOWN REKENING ---
  Widget _buildAccountDropdown(List<AccountModel> accounts) {
    if (accounts.isEmpty) {
      return GestureDetector(
        onTap: _showNoAccountDialog,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: const [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Text("Rekening tidak tersedia. Klik untuk tambah.", style: TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ),
        ),
      );
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
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: accounts.map((AccountModel account) {
            return DropdownMenuItem<AccountModel>(
              value: account,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: account.colors.isNotEmpty ? account.colors[0] : Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.credit_card, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          account.title,
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2E4053)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          account.saldo,
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (newValue) => setState(() => _selectedAccount = newValue),
        ),
      ),
    );
  }

  // --- WIDGET HELPER LAINNYA ---
  Widget _buildCategoryDropdown() {
    if (_currentCategories.isEmpty) return const SizedBox();
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
          items: _currentCategories.map((category) {
            return DropdownMenuItem<CategoryItem>(
              value: category,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Icon(category.icon, color: category.color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2E4053)),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (newValue) => setState(() => _selectedCategory = newValue),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.only(bottom: 40),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, color: Color(0xFF2E4053)),
                ),
              ),
              const SizedBox(width: 16),
              const Text("Add Transaction", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E4053))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(16)),
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
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
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

  Widget _buildInputLabel(String label) => Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(bottom: 8, left: 4), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87))));

  Widget _buildTextField({required TextEditingController controller, required String hint, IconData? icon, int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2E4053)),
        decoration: InputDecoration(prefixIcon: Icon(icon, color: Colors.grey), hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: _addTransactionToProvider,
            child: const Text("Simpan Transaksi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}