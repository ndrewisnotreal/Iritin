import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  // Index menu bawah (0: Home, 1: History, dst)
  int _selectedIndex = 0;

  // Halaman Custom yang numpang tampil di dalam Dashboard (misal: Analytics, Accounts)
  Widget? _subPage;

  int get selectedIndex => _selectedIndex;
  Widget? get subPage => _subPage;

  // Ganti Tab Bawah
  void setIndex(int index) {
    _selectedIndex = index;
    _subPage = null; // Kalau ganti tab, reset halaman detailnya
    notifyListeners();
  }

  // Buka Halaman Detail (Navbar Tetap Ada)
  void openSubPage(Widget page) {
    _subPage = page;
    notifyListeners();
  }

  // Tutup Halaman Detail (Balik ke Tab Utama)
  void closeSubPage() {
    _subPage = null;
    notifyListeners();
  }

  // Helper buat tombol Back Android
  bool onWillPop() {
    if (_subPage != null) {
      closeSubPage();
      return false; // Jangan keluar app, tapi tutup subpage dulu
    }
    return true; // Keluar app
  }
}
