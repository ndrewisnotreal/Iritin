import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iritin/providers/dashboard_provider.dart';
import 'package:iritin/providers/transaction_provider.dart';
import 'package:iritin/screens/dashboard/analytics_screen.dart';
import 'package:iritin/screens/dashboard/accounts_screen.dart';
import 'package:iritin/screens/anggaran/add_anggaran_screen.dart';
import 'package:iritin/screens/anggaran/anggaran_screen.dart';

// --- WARNA & KONSTANTA ---
const Color primaryGreen = Color(0xFFD1F333);
const Color accentGreen = Color(0xFFF2FFB0);
const Color textColor = Color(0xFF2E4053);
const Color primaryDark = Color(0xFF558B2F);

class AppColors {
  static const Color primary = primaryGreen;
  static const Color textPrimary = textColor;
  static const Color primaryDark = accentGreen;
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // --- LOGIC: Hitung Data Mingguan (Senin-Minggu) ---
  List<FlSpot> _getWeeklySpots(List<Map<String, dynamic>> transactions) {
    List<double> weeklyTotals = List.filled(7, 0.0);

    DateTime now = DateTime.now();
    // Cari tanggal hari Senin minggu ini
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    monday = DateTime(
      monday.year,
      monday.month,
      monday.day,
    ); // Reset jam ke 00:00

    for (var tx in transactions) {
      // Hanya ambil Pengeluaran (Type 1)
      if (tx['type'] == 1) {
        try {
          DateTime txDate = DateFormat('dd/MM/yyyy').parse(tx['date']);
          int diffDays = txDate.difference(monday).inDays;

          if (diffDays >= 0 && diffDays < 7) {
            weeklyTotals[diffDays] += (tx['amount'] as num).toDouble();
          }
        } catch (e) {
          // Ignore error parsing
        }
      }
    }

    return List.generate(7, (index) {
      return FlSpot(index.toDouble(), weeklyTotals[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFinanceCards(transactionProvider),
                  const SizedBox(height: 24),

                  // Analytics Card (Grafik Mingguan)
                  _buildAnalyticsCard(context, transactionProvider),

                  const SizedBox(height: 24),

                  // Riwayat Transaksi
                  _buildTransactionHistorySection(transactionProvider),
                  const SizedBox(height: 24),

                  // Fitur Lainnya
                  _buildMoreFeatures(context),

                  const SizedBox(height: 100), // Spasi bawah untuk navigasi
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. HEADER (DINAMIS FIREBASE AUTH)
  Widget _buildHeader(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    String displayName = "Pengguna";
    String? photoUrl = user?.photoURL;
    String initials = "U";

    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        displayName = user.displayName!;
      } else if (user.email != null) {
        String emailName = user.email!.split('@')[0];
        displayName = emailName[0].toUpperCase() + emailName.substring(1);
      }

      List<String> words = displayName.trim().split(" ");
      if (words.isNotEmpty) {
        initials = words[0][0].toUpperCase();
        if (words.length > 1) {
          initials += words[1][0].toUpperCase();
        }
      }
    }

    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFF0F0F0),
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo, $displayName!",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  "Welcome Back",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              const Icon(Icons.notifications_outlined, size: 28),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. KARTU SALDO & PENGELUARAN
  Widget _buildFinanceCards(TransactionProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildCardItem(
            title: "Saldo",
            amount: TransactionProvider.formatRupiah(provider.balance),
            icon: Icons.add_circle_outline,
            bgColor: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCardItem(
            title: "Pengeluaran",
            amount: TransactionProvider.formatRupiah(provider.totalExpense),
            icon: Icons.remove_red_eye_outlined,
            bgColor: const Color(0xFF1F4E5F),
          ),
        ),
      ],
    );
  }

  // 3. ANALYTICS CARD (FIXED VERSION)
  Widget _buildAnalyticsCard(
    BuildContext context,
    TransactionProvider provider,
  ) {
    // A. Siapkan Data
    final List<FlSpot> spots = _getWeeklySpots(provider.transactions);

    // B. Hitung Batas Atas Grafik
    double maxY = 0;
    for (var spot in spots) {
      if (spot.y > maxY) maxY = spot.y;
    }
    maxY = maxY == 0 ? 100 : maxY * 1.2;

    return GestureDetector(
      onTap: () {
        context.read<DashboardProvider>().openSubPage(const AnalyticsScreen());
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            // Header Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.pie_chart, size: 24, color: Color(0xFF4B5320)),
                    SizedBox(width: 8),
                    Text(
                      "Analytics",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD2F801),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // CHART AREA
            AspectRatio(
              aspectRatio: 1.70,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    // LABEL BAWAH (HARI) - FIX PENGGUNAAN PADDING
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          String text;
                          switch (value.toInt()) {
                            case 0:
                              text = 'M';
                              break;
                            case 1:
                              text = 'T';
                              break;
                            case 2:
                              text = 'W';
                              break;
                            case 3:
                              text = 'T';
                              break;
                            case 4:
                              text = 'F';
                              break;
                            case 5:
                              text = 'S';
                              break;
                            case 6:
                              text = 'S';
                              break;
                            default:
                              return Container();
                          }
                          // Menggunakan Padding sebagai pengganti SideTitleWidget
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(text, style: style),
                          );
                        },
                      ),
                    ),

                    // LABEL KIRI (ANGKA)
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return Container();
                          return Text(
                            "${(value / 1000).toStringAsFixed(0)}k",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots.isEmpty ? [const FlSpot(0, 0)] : spots,
                      isCurved: false,
                      color: const Color(0xFFD2F801),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: const Color(0xFF558B2F),
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. RIWAYAT TRANSAKSI
  Widget _buildTransactionHistorySection(TransactionProvider provider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Riwayat Transaksi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Lihat semua >",
              style: TextStyle(fontSize: 12, color: AppColors.primaryDark),
            ),
          ],
        ),
        const SizedBox(height: 16),

        provider.transactions.isEmpty
            ? _buildEmptyState()
            : SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: provider.transactions.length,
                  itemBuilder: (context, index) {
                    final item = provider.transactions[index];
                    return Row(
                      children: [
                        _buildTransactionCard(
                          item['title'] ?? 'Transaksi',
                          TransactionProvider.formatRupiah(item['amount'] ?? 0),
                          item['category'] ?? 'Umum',
                        ),
                        const SizedBox(width: 12),
                      ],
                    );
                  },
                ),
              ),
      ],
    );
  }

  // 5. FITUR LAINNYA
  Widget _buildMoreFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "More Features",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFeatureButton(
              context: context,
              label: "Daftar Kategori",
              iconWidget: const Icon(
                Icons.dashboard,
                size: 30,
                color: Colors.black,
              ),
              onTap: () {},
            ),
            _buildFeatureButton(
              context: context,
              label: "Atur Anggaran",
              iconWidget: Image.asset(
                'assets/icons/icon_anggaran.png',
                height: 30,
                width: 30,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.pie_chart, size: 30),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnggaranScreen(),
                  ),
                );
              },
            ),
            _buildFeatureButton(
              context: context,
              label: "Akun Rekening",
              iconWidget: const Icon(
                Icons.account_balance_wallet,
                size: 30,
                color: Colors.black,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: const [
          Icon(Icons.receipt_long_outlined, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text("Belum ada transaksi", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(String title, String amount, String category) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFF66),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                category,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem({
    required String title,
    required String amount,
    required IconData icon,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Icon(icon, color: Colors.white70, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton({
    required BuildContext context,
    required String label,
    required Widget iconWidget,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width / 3.8,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFFF66),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30, width: 30, child: iconWidget),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
