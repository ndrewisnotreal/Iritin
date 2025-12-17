import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iritin/providers/dashboard_provider.dart';
import 'package:iritin/styling/app_colors.dart' as style;
import 'package:iritin/screens/dashboard/add_transaction_screen.dart';
import 'package:iritin/screens/dashboard/history_screen.dart';
import 'package:iritin/screens/dashboard/home_screen.dart';
import 'package:iritin/screens/reminder/billreminder_screen.dart';
// FIX: Import halaman Settings yang baru dibuat
import 'package:iritin/screens/dashboard/settings_screen.dart';

// --- KONSTANTA WARNA DARI SPLITBILL SCREEN ---
const Color primaryGreen = Color(0xFFD1F333);
const Color accentGreen = Color(0xFFF2FFB0);
const Color textColor = Color(0xFF2E4053);
const Color darkGreen = Color(0xFF558B2F);
// ---------------------------------------------

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // WIDGET BARU: Membangun Item Ikon Navbar
  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    int index,
    int selectedIndex,
  ) {
    bool isSelected = index == selectedIndex;
    final Color iconColor = isSelected ? darkGreen : Colors.black54;

    // Jika ini adalah tombol FAB (Index 2 - Tombol Tambah)
    if (index == 2) {
      return BottomNavigationBarItem(
        icon: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            color: primaryGreen,
            shape: BoxShape.circle,
          ),
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

    // FIX: List Halaman Utama (Index 2 diloncati karena tombol aksi)
    final List<Widget> mainPages = [
      const HomeScreen(), // Index 0: Home
      const HistoryScreen(), // Index 1: History
      const SizedBox(), // Index 2: Placeholder (karena tombol +)
      const BillReminderScreen(), // Index 3: Bill Reminder
      const SettingsScreen(), // Index 4: Settings (Halaman Baru)
    ];

    // 2. Pasang WillPopScope buat handle tombol Back HP
    return WillPopScope(
      onWillPop: () async => provider.onWillPop(),
      child: Scaffold(
        backgroundColor: style.AppColors.background,

        // 3. LOGIC UTAMA: Tampilkan halaman sesuai index atau subPage jika ada
        body: provider.subPage ?? mainPages[provider.selectedIndex],

        // Implementasi Navbar
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

          // 5. UPDATE LOGIC NAVIGASI
          onTap: (index) {
            // FIX: Kalau user klik tombol "+" di tengah (Index 2)
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
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
            _buildNavItem(
              Icons.home_outlined,
              'Home',
              0,
              provider.selectedIndex,
            ),
            _buildNavItem(Icons.history, 'History', 1, provider.selectedIndex),
            _buildNavItem(
              Icons.add,
              '',
              2,
              provider.selectedIndex,
            ), // Tombol Tengah (+)
            _buildNavItem(
              Icons.receipt_long,
              'Bill',
              3,
              provider.selectedIndex,
            ),
            _buildNavItem(
              Icons.settings_outlined,
              'Setting',
              4,
              provider.selectedIndex,
            ),
          ],
        ),
      ),
    );
  }
}
