import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iritin/providers/dashboard_provider.dart';
import 'package:iritin/styling/app_colors.dart' as style; 
import 'package:iritin/screens/dashboard/add_transaction_screen.dart'; 
import 'package:iritin/screens/dashboard/history_screen.dart';
import 'package:iritin/screens/dashboard/home_screen.dart';
// FIX IMPORT: Halaman SplitBillScreen dihapus
import 'package:iritin/screens/reminder/billreminder_screen.dart'; // BillReminder tetap ada (Index 3)

// --- KONSTANTA WARNA DARI SPLITBILL SCREEN (Dipertahankan untuk styling Navbar) ---
const Color primaryGreen = Color(0xFFD1F333); 
const Color accentGreen = Color(0xFFF2FFB0); 
const Color textColor = Color(0xFF2E4053); 
const Color darkGreen = Color(0xFF558B2F); 
// ---------------------------------------------


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // WIDGET BARU: Membangun Item Ikon Navbar yang Sesuai Desain SplitBill
  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index, int selectedIndex) {
    bool isSelected = index == selectedIndex;
    final Color iconColor = isSelected ? darkGreen : Colors.black54;

    // Jika ini adalah tombol FAB (Index 2)
    if (index == 2) {
      return BottomNavigationBarItem(
        icon: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle), 
          child: const Icon(Icons.add, color: Colors.black, size: 28), 
        ),
        label: '',
      );
    }

    return BottomNavigationBarItem(
      icon: Icon(icon, color: iconColor, size: 28),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Ambil data dari Provider
    final provider = context.watch<DashboardProvider>();

    // FIX 1: List Halaman Utama Dihapus SplitBillScreen (Index 2)
    final List<Widget> mainPages = [
      const HomeScreen(), // Index 0
      const HistoryScreen(), // Index 1
      // FIX: Index 2 sekarang menjadi AddTransactionScreen placeholder (tetapi tidak boleh ditampilkan)
      // Kita kembalikan ke Home Screen atau SizedBox saja, karena Index 2 di handle di onTap.
      const SizedBox(), 
      const BillReminderScreen(), // Index 3: Bill
      const Center(child: Text("Halaman Settings")), // Index 4
    ];

    // 2. Pasang WillPopScope buat handle tombol Back HP
    return WillPopScope(
      onWillPop: () async => provider.onWillPop(),
      child: Scaffold(
        backgroundColor: style.AppColors.background, 

        // 3. LOGIC UTAMA: Index 2 akan menampilkan SizedBox() jika tidak ada subPage.
        body: provider.subPage ?? mainPages[provider.selectedIndex],

        // Implementasi Navbar Sesuai Styling SplitBill
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: accentGreen,
          
          selectedItemColor: darkGreen, 
          unselectedItemColor: Colors.black54, 
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),

          // 4. Ambil index dari Provider
          currentIndex: provider.selectedIndex,

          // 5. UPDATE LOGIC NAVIGASI (Tombol +)
          onTap: (index) {
            // FIX: Kalau user klik tombol "+" di tengah (Index 2), arahkan ke AddTransactionScreen
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // FIX: Navigasi ke Add Transaction
                  builder: (context) => const AddTransactionScreen(), 
                ),
              );
            }
            // Kalau klik tab lain (Home, History, Bill, Settings), switch tab.
            else {
              provider.setIndex(index);
            }
          },

          items: [
            _buildNavItem(Icons.home_outlined, 'Home', 0, provider.selectedIndex),
            _buildNavItem(Icons.history, 'History', 1, provider.selectedIndex),
            _buildNavItem(Icons.add, '', 2, provider.selectedIndex), // Tombol Tengah (+)
            _buildNavItem(Icons.receipt_long, 'Bill', 3, provider.selectedIndex),
            _buildNavItem(Icons.settings_outlined, 'Setting', 4, provider.selectedIndex),
          ],
        ),
      ),
    );
  }
}