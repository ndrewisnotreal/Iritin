import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:iritin/styling/app_colors.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui'; // Wajib untuk efek blur (BackdropFilter)
// Pastikan path ini benar:
import 'package:iritin/models/account_provider.dart'; 

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

  // --- WIDGET LAYAR WARNING (PROMPT) ---
  void _showWarningPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false, // User wajib klik OK
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black.withOpacity(0.4),
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
                    const Icon(
                      Icons.warning_amber_rounded, 
                      size: 60, 
                      color: Colors.orange, 
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Saldo Tidak Valid",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFF2E4053),
                        decoration: TextDecoration.none, // Menghilangkan garis bawah kuning
                      ), 
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Saldo yang diisi harus melebihi 0 Rp.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey, 
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ), 
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD2F801), // Warna Lime
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "OKE", 
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _submitAccount() {
    if (_nameController.text.isEmpty || _balanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama dan Saldo harus diisi.")),
      );
      return;
    }

    // --- LOGIKA VALIDASI SALDO ---
    final String cleanBalance = _balanceController.text.replaceAll('.', '').replaceAll(',', '');
    final double? balanceAmount = double.tryParse(cleanBalance);

    if (balanceAmount == null || balanceAmount <= 0) {
      _showWarningPrompt(); // Munculkan layar warning jika 0
      return;
    }

    final newAccount = AccountModel(
      id: _uuid.v4(), 
      title: _nameController.text,
      saldo: "Rp${cleanBalance}",
      lastUsed: "Baru", 
      colors: _defaultColors,
    );

    context.read<AccountProvider>().addAccount(newAccount);
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