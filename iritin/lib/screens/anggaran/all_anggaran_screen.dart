import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- ASUMSI WARNA ---
const Color primaryGreen = Color(0xFFD1F333); 
const Color accentGreen = Color(0xFFF2FFB0); 
const Color textColor = Color(0xFF2E4053); 
const Color darkGreen = Color(0xFF558B2F); 
const Color softYellow = Color(0xFFF5FFCC);
// --------------------

class AnggaranData {
  final String categoryName;
  final IconData icon;
  final Color iconColor;
  final int totalBudget;
  final int usedAmount;

  AnggaranData({
    required this.categoryName,
    required this.icon,
    required this.iconColor,
    required this.totalBudget,
    required this.usedAmount,
  });

  int get remainingAmount => totalBudget - usedAmount;
  double get progress => totalBudget > 0 ? usedAmount / totalBudget : 0.0;
}

class AllAnggaranScreen extends StatefulWidget {
  const AllAnggaranScreen({super.key});

  @override
  State<AllAnggaranScreen> createState() => _AllAnggaranScreenState();
}

class _AllAnggaranScreenState extends State<AllAnggaranScreen> {
  
  // Data Dummy Anggaran
  final List<AnggaranData> _dummyAnggaran = [
    AnggaranData(categoryName: 'Pendidikan', icon: Icons.school, iconColor: Colors.blue.shade700, totalBudget: 1000000, usedAmount: 600000),
    AnggaranData(categoryName: 'Makanan', icon: Icons.restaurant, iconColor: Colors.red.shade700, totalBudget: 900000, usedAmount: 700000),
    AnggaranData(categoryName: 'Fashion', icon: Icons.checkroom, iconColor: Colors.pink.shade700, totalBudget: 300000, usedAmount: 200000),
    AnggaranData(categoryName: 'Hiburan', icon: Icons.sports_esports, iconColor: Colors.purple.shade700, totalBudget: 200000, usedAmount: 100000),
    AnggaranData(categoryName: 'Transportasi', icon: Icons.directions_bus, iconColor: Colors.orange.shade700, totalBudget: 500000, usedAmount: 300000),
  ];
  
  // Data Overview
  final _totalAnggaran = 2900000;
  final _terpakai = 1900000;
  
  // State Bulan Aktif (sesuai gambar: Oktober)
  String _activeMonth = 'Oktober';
  
  // Helper untuk format Rupiah
  final _currencyFormatter = NumberFormat('#,##0', 'id_ID');
  String _formatRupiah(int amount) => 'Rp${_currencyFormatter.format(amount)}';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderOverview(),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildMonthlyBudgetHeader(),
                  const SizedBox(height: 20),
                  
                  // Daftar Anggaran per Kategori
                  ..._dummyAnggaran.map((data) => _buildCategoryBudgetCard(data)).toList(),
                  
                  const SizedBox(height: 50),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // 1. Header Overview
  Widget _buildHeaderOverview() {
    final sisa = _totalAnggaran - _terpakai;
    final progress = _totalAnggaran > 0 ? _terpakai / _totalAnggaran : 0.0;
    
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigasi & Judul
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                ),
              ),
              const Center(
                child: Text(
                  "Overview Anggaran",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Total Budget
          Text(
            'Tersisa ${_formatRupiah(sisa)} dari ${_formatRupiah(_totalAnggaran)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
          ),
          const SizedBox(height: 10),
          
          // Progress Bar Besar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: softYellow,
              valueColor: const AlwaysStoppedAnimation<Color>(darkGreen),
              minHeight: 15,
            ),
          ),
          const SizedBox(height: 15),
          
          // Keterangan Jumlah
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryPill('Total Anggaran', _formatRupiah(_totalAnggaran), primaryGreen),
              _buildSummaryPill('Terpakai', _formatRupiah(_terpakai), primaryGreen),
              _buildSummaryPill('Tersisa', _formatRupiah(sisa), primaryGreen),
            ],
          )
        ],
      ),
    );
  }

  // Widget Pill Ringkasan (digunakan di Header Overview)
  Widget _buildSummaryPill(String title, String amount, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.5), // Warna background pill
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: textColor)),
          Text(amount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  // 2. Header Anggaran Bulanan (Filter Bulan)
  Widget _buildMonthlyBudgetHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul Utama dengan Garis Bawah
        Center(
          child: Container(
            padding: const EdgeInsets.only(bottom: 5),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: textColor, width: 2.0),
              ),
            ),
            child: const Text(
              "Anggaran Bulanan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Kontrol Bulan
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Kontrol Panah
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: darkGreen),
                  onPressed: () { /* TODO: Ganti bulan mundur */ },
                ),
                Text(_activeMonth, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkGreen)),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: darkGreen),
                  onPressed: () { /* TODO: Ganti bulan maju */ },
                ),
              ],
            ),
            
            // Ikon Kalender & Download
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.calendar_today_outlined, color: darkGreen),
                  onPressed: () { /* TODO: Pilih bulan */ },
                ),
                IconButton(
                  icon: const Icon(Icons.file_download_outlined, color: darkGreen),
                  onPressed: () { /* TODO: Download */ },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
  
  // 3. Kartu Anggaran per Kategori
  Widget _buildCategoryBudgetCard(AnggaranData data) {
    // Tentukan warna progress bar (Hijau jika sisa > 0, Kuning jika progress mendekati 100%)
    Color progressColor = data.remainingAmount >= 0 ? darkGreen : Colors.red;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      color: accentGreen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon dan Nama Kategori
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: data.iconColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(data.icon, color: Colors.white, size: 24), 
                    ),
                    const SizedBox(width: 12),
                    Text(data.categoryName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                  ],
                ),
                // Total Anggaran Kategori
                Text(
                  _formatRupiah(data.totalBudget),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: data.remainingAmount >= 0 ? textColor : Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: data.progress.clamp(0.0, 1.0), // Clamp agar tidak melebihi 1.0 (meski terpakai > anggaran)
                backgroundColor: softYellow,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),

            // Rincian Terpakai dan Tersisa
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Terpakai: ${_formatRupiah(data.usedAmount)}',
                  style: const TextStyle(fontSize: 12, color: textColor),
                ),
                Text(
                  'Tersisa: ${_formatRupiah(data.remainingAmount)}',
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold, 
                    color: progressColor, // Warna merah jika over budget
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}