import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:iritin/providers/dashboard_provider.dart'; 
import 'package:iritin/styling/app_colors.dart' as style;
import 'package:iritin/screens/dashboard/add_balance_screen.dart';
import 'package:iritin/screens/dashboard/add_account_screen.dart'; 
import 'package:iritin/screens/dashboard/analytics_screen.dart'; 
import 'package:iritin/models/account_provider.dart' as acct_provider; 
import 'package:iritin/screens/dashboard/home_screen.dart'; 
import 'package:intl/intl.dart'; 


class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});
  
  // HELPER: Membersihkan dan memformat saldo untuk tampilan
  String _formatSaldoDisplay(String saldoString) {
      String cleanString = saldoString
          .replaceAll(RegExp(r'[Rp\.]'), '')
          .replaceAll(',', '') 
          .trim();
          
      double? amount = double.tryParse(cleanString);

      if (amount == null) return saldoString; 

      final formatter = NumberFormat.currency(
          locale: 'id_ID', 
          symbol: 'Rp', 
          decimalDigits: 0
      );
      
      return formatter.format(amount);
  }


  // Metode Dialog
  void _showDeleteConfirmation(BuildContext context, acct_provider.AccountModel account) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: Color(0xFFE53935),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Hapus Rekening ${account.title}?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Rekening akan terhapus dan tidak dapat dipulihkan kembali. Apakah anda yakin?",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD2F801),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: const Text(
                          "Batal",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          // Panggil Provider dengan alias yang benar
                          dialogContext.read<acct_provider.AccountProvider>().deleteAccount(account.id);
                          
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Rekening ${account.title} berhasil dihapus"),
                            ),
                          );
                        },
                        child: const Text(
                          "Hapus",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan context.watch dengan alias yang benar
    final accountProvider = context.watch<acct_provider.AccountProvider>();
    final accountsList = accountProvider.accounts;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            // Judul Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Akun Rekening",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List Kartu Vertikal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: accountsList.map((account) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildAccountCard(context, account),
                  );
                }).toList(),
              ),
            ),
            
            // JIKA DAFTAR KOSONG
            if (accountsList.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Tidak ada rekening terdaftar.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),


            const SizedBox(height: 24),

            // Tombol Tambah Rekening
            _buildAddAccountButton(context),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 1. HEADER
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: style.AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // FIX: Menggunakan Navigator.pop(context) untuk kembali ke HomeScreen
                  // Karena HomeScreen di-push melalui Navigator.push dari Home Dashboard
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
              const SizedBox(width: 8),
              const Text(
                "Akun Rekening",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Overview Rekening",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Text(
            "Total Saldo dan Progres Keuangan",
            style: TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.6,
              minHeight: 8,
              backgroundColor: Colors.white54,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Keuangan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Text(
                "Tujuan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. KARTU REKENING
  Widget _buildAccountCard(BuildContext context, acct_provider.AccountModel account) {
    // Panggil helper untuk memastikan saldo diformat
    final formattedSaldo = _formatSaldoDisplay(account.saldo);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: account.colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: account.colors.last.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                account.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  // TOMBOL EDIT (Keypad)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddBalanceScreen(), 
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // TOMBOL HAPUS (Memanggil dialog dengan data rekening)
                  GestureDetector(
                    onTap: () {
                      _showDeleteConfirmation(context, account); 
                    },
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            // Menggunakan saldo yang sudah diformat
            "Saldo: $formattedSaldo",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),

          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Last Used : ${account.lastUsed}",
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  value: 0.3, 
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. TOMBOL TAMBAH
  Widget _buildAddAccountButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFF66),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // AddAccountScreen diimpor di baris 7
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddAccountScreen()), 
            );
          },
          borderRadius: BorderRadius.circular(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_circle_outline, color: Colors.black),
              SizedBox(width: 8),
              Text(
                "Tambahkan Rekening Baru",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}