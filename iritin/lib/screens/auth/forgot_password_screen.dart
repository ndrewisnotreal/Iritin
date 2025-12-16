import 'package:flutter/material.dart';
import 'package:iritin/auth/auth_service.dart'; // Import Service

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FDCF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Ilustrasi Gembok/Reset
            Image.network(
              'https://cdn-icons-png.flaticon.com/512/6357/6357048.png',
              height: 150,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.lock_reset, size: 100, color: Colors.blue),
            ),
            const SizedBox(height: 30),

            const Text(
              "Lupa Password?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Masukkan email Anda. Kami akan mengirimkan link untuk mereset kata sandi.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Input Email
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: "Contoh: wildan@gmail.com",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Kirim
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD2F801), // Lime
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (_emailController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Email wajib diisi!")),
                    );
                    return;
                  }

                  // 1. Loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (c) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  // 2. Panggil Firebase (Kirim Link)
                  final message = await AuthService().resetPassword(
                    email: _emailController.text.trim(),
                  );

                  // Tutup Loading
                  if (!mounted) return;
                  Navigator.pop(context);

                  // 3. Cek Hasil
                  if (message == null) {
                    // BERHASIL -> Muncul Dialog
                    _showSuccessDialog(context);
                  } else {
                    // GAGAL -> Muncul Error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Gagal: $message"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text(
                  "Kirim Link Reset",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Sukses
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mark_email_read, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            const Text(
              "Link Terkirim!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Silakan cek Inbox atau Spam di email Anda. Klik link tersebut untuk membuat password baru.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD2F801),
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  // Tutup Dialog & Balik ke Login
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Kembali ke Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
