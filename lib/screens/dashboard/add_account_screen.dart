import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:iritin/styling/app_colors.dart';
import 'package:uuid/uuid.dart';
// Pastikan path ini benar:
import 'package:iritin/providers/account_provider.dart'; 
// Mengambil AccountModel
import 'package:iritin/providers/account_provider.dart' show AccountModel; 

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final Uuid _uuid = const Uuid(); 
  
  final List<Color> _defaultColors = [
    const Color(0xFF13111A), 
    const Color(0xFF434149),
  ];


  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }
  
  void _submitAccount() {
    // 1. Basic empty check
    if (_nameController.text.isEmpty || _balanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama dan Saldo harus diisi.")),
      );
      return;
    }
    
    // 2. Data Cleaning: Hapus pemisah ribuan (titik/koma) dari input untuk validasi
    final rawBalanceInput = _balanceController.text;
    final cleanBalanceString = rawBalanceInput.replaceAll('.', '').replaceAll(',', '').trim();
    
    // 3. Validation: Check if it's a valid number and greater than zero
    final double? balanceAmount = double.tryParse(cleanBalanceString);

    if (balanceAmount == null || balanceAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tolong isi format saldo dengan benar (harus angka dan lebih dari nol)!"), 
          backgroundColor: Colors.red
        ),
      );
      return;
    }

    // 4. Proceed with Account Creation
    final newAccount = AccountModel(
      id: _uuid.v4(), 
      title: _nameController.text,
      // Gunakan cleanBalanceString yang sudah divalidasi
      saldo: "Rp$cleanBalanceString", 
      lastUsed: "Baru", 
      colors: _defaultColors,
    );

    context.read<AccountProvider>().addAccount(newAccount);

    // Navigasi kembali (sesuai permintaan user sebelumnya: kembali ke AccountsScreen)
    Navigator.pop(context);
  }
  
  @override
  Widget build(BuildContext context) {
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
                  _buildFormCard(),

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
                Icon(Icons.wallet, size: 60, color: Colors.deepOrangeAccent),
                SizedBox(height: 10),
                Text(
                  "Tambah Rekening",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
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
                "Informasi Rekening",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputLabel("Nama Rekening"),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameController,
                  hint: "Kartu Kredit",
                  icon: Icons.credit_card,
                ),

                const SizedBox(height: 16),

                _buildInputLabel("Saldo"),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _balanceController,
                  hint: "5.000.000",
                  prefixText: "Rp   ",
                  // Sudah menggunakan keyboardType: TextInputType.number, tetapi validasi tetap dibutuhkan
                  keyboardType: TextInputType.number, 
                ),
              ],
            ),
          ),
        ],
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
    IconData? icon,
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
          icon: icon != null ? Icon(icon, color: Colors.black87) : null,
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
        onPressed: _submitAccount,
        child: const Text(
          "Tambahkan",
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