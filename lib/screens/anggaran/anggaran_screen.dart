import 'package:flutter/material.dart';
// Import kedua layar tujuan
import 'add_anggaran_screen.dart'; 
import 'all_anggaran_screen.dart';

// --- ASUMSI WARNA ---
const Color primaryGreen = Color(0xFFD1F333); 
const Color textColor = Color(0xFF2E4053); 
const Color darkGreen = Color(0xFF558B2F); 
// --------------------

// FIX: Ini adalah AnggaranScreen yang berfungsi sebagai Menu
class AnggaranScreen extends StatelessWidget {
  const AnggaranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tombol 1: Buat Anggaran (Navigasi ke AddAnggaranScreen)
                  _buildMenuButton(
                    context,
                    title: "Buat Anggaran",
                    subtitle: "Tambahkan alokasi dana baru per kategori.",
                    icon: Icons.add_circle_outline,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddAnggaranScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Tombol 2: Lihat Semua Anggaran
                  _buildMenuButton(
                    context,
                    title: "Lihat Semua Anggaran",
                    subtitle: "Lihat ringkasan dan detail penggunaan anggaran bulanan.",
                    icon: Icons.list_alt,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AllAnggaranScreen()),
                      );
                    },
                  ),
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
          
          const Center(
            child: Text(
              "Atur Anggaran", // Judul Utama Menu
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onPressed}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: darkGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: darkGreen, size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: darkGreen),
            ],
          ),
        ),
      ),
    );
  }
}