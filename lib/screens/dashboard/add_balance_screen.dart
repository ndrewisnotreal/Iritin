import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import 'package:iritin/styling/app_colors.dart';
// Sesuaikan path import AccountProvider dan AccountModel Anda
import 'package:iritin/providers/account_provider.dart'; 

class AddBalanceScreen extends StatefulWidget {
  const AddBalanceScreen({super.key});

  @override
  State<AddBalanceScreen> createState() => _AddBalanceScreenState();
}

class _AddBalanceScreenState extends State<AddBalanceScreen> {
  
  final TextEditingController _amountController = TextEditingController();
  AccountModel? _selectedAccount; 

  @override
  void initState() {
    super.initState();
    // Inisialisasi _selectedAccount dengan akun pertama jika ada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accounts = context.read<AccountProvider>().accounts;
      if (accounts.isNotEmpty) {
        setState(() {
          _selectedAccount = accounts.first;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submitBalance() {
    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih Rekening terlebih dahulu.")),
      );
      return;
    }
    
    // 1. Bersihkan input nominal dari titik/koma (pemisah ribuan)
    final amountText = _amountController.text.replaceAll('.', '').replaceAll(',', '');
    final amountToAdd = double.tryParse(amountText);

    if (amountToAdd == null || amountToAdd <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Input Saldo tidak valid.")),
      );
      return;
    }

    // 2. Panggil fungsi update di Provider
    context.read<AccountProvider>().updateAccountBalance(
      _selectedAccount!.id, 
      amountToAdd,
    );

    // 3. Beri feedback dan kembali
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Saldo ${_selectedAccount!.title} berhasil ditambahkan!")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Ambil daftar akun dari provider
    final accounts = context.watch<AccountProvider>().accounts;
    
    // Logika untuk memastikan selectedAccount masih ada dalam daftar
    if (accounts.isEmpty && _selectedAccount != null) {
        _selectedAccount = null;
    } else if (accounts.isNotEmpty && _selectedAccount == null) {
        _selectedAccount = accounts.first;
    }
    
    return Scaffold(
      backgroundColor: Colors.white, 
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          _buildHeader(context),

          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: const BoxDecoration(
                color: Color(0xFFFCFFD9), 
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  _buildFormCard(accounts), 

                  const Spacer(),

                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      color: AppColors.primary,
      child: Stack(
        children: [
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios, size: 24),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(height: 30),
                Icon(Icons.add_circle, size: 60, color: Colors.deepOrangeAccent),
                SizedBox(height: 10),
                Text(
                  "Tambah Saldo Rekening",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(List<AccountModel> accounts) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9), 
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFD2F801), 
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Center(
              child: Text(
                "Informasi Saldo",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputLabel("Pilih Rekening"),
                const SizedBox(height: 8),
                _buildAccountDropdown(accounts), // DROPDOWN

                const SizedBox(height: 16),

                _buildInputLabel("Nominal Tambahan Saldo"),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _amountController,
                  hint: "50.000",
                  prefixText: "Rp   ",
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget Dropdown
  Widget _buildAccountDropdown(List<AccountModel> accounts) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black87,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: accounts.isEmpty
          ? const Center(child: Text("Tidak ada rekening yang tersedia.", style: TextStyle(color: Colors.black54)))
          : DropdownButtonHideUnderline(
              child: DropdownButton<AccountModel>(
                isExpanded: true,
                value: _selectedAccount,
                hint: const Text("Pilih Akun", style: TextStyle(color: Colors.black54)),
                items: accounts.map((AccountModel account) {
                  return DropdownMenuItem<AccountModel>(
                    value: account,
                    child: Text(
                      "${account.title} (${account.saldo})", // Tampilkan Saldo saat ini
                      style: const TextStyle(fontWeight: FontWeight.bold),
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


  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black87,
          width: 1,
        ), 
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: prefixText != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 14, left: 0),
                  child: Text(
                    prefixText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                )
              : null,
          border: InputBorder.none, 
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD2F801),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        onPressed: _submitBalance, // Panggil _submitBalance
        child: const Text(
          "Tambahkan Saldo",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}