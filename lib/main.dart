// lib/main.dart (MODIFIKASI TOTAL)

import 'package:flutter/material.dart';
// Impor semua file halaman dan model
import 'package:iritin/dashboard_page.dart';
import 'package:iritin/history_page.dart';
import 'package:iritin/bills_screen.dart'; 
import 'package:iritin/transaction_model.dart'; // Wajib

void main() {
  runApp(const IritinApp());
}

// ... (Class IritinApp tetap sama) ...

class IritinApp extends StatelessWidget {
  const IritinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iritin App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal, 
        appBarTheme: const AppBarTheme(
          color: Colors.teal,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(), 
    );
  }
}

// --- MAIN SCREEN: SEKARANG BERTINDAK SEBAGAI STATE MANAGER UTAMA ---
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  // 1. PINDAH DATA: Data Transaksi sekarang disimpan di sini!
  final List<Transaction> _transactions = []; 

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fungsi untuk Menambah Transaksi (Dibagikan ke Dashboard)
  void _addTransaction(Transaction newTransaction) {
    setState(() {
      _transactions.add(newTransaction);
      // Opsional: Urutkan
      _transactions.sort((a, b) => b.date.compareTo(a.date)); 
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definisi Daftar Halaman
    final List<Widget> _widgetOptions = <Widget>[
      // Kirim data transaksi dan fungsi penambah transaksi ke Dashboard
      DashboardPage(
        transactions: _transactions,
        addTransaction: _addTransaction, 
      ),
      // Kirim data transaksi ke Halaman Riwayat
      HistoryPage(transactions: _transactions), 
      // Halaman Fitur Lain (Tidak perlu data transaksi)
      const BillsScreen(), 
    ];

    return Scaffold(
      // 2. GUNAKAN INDEXEDSTACK: Menjaga state semua halaman tetap hidup
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      
      // Tombol FAB tetap di DashboardPage, tidak di sini.
      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          // BottomNavigationBarItem(icon: Icon(Icons.wallet_travel), label: 'Fitur Lain'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}