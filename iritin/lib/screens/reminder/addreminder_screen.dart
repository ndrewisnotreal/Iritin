import 'package:flutter/material.dart';
import 'package:iritin/models/bill_provider.dart';
import 'package:iritin/services/notification_service.dart'; // Import Service Notifikasi

// Definisi Warna Kunci
const Color primaryGreen = Color(0xFFD1F333);
const Color accentGreen = Color(0xFFF2FFB0);
const Color textColor = Color(0xFF2E4053);

// Model untuk menampung data kategori dan ikonnya
class CategoryItem {
  final String name;
  final IconData icon;
  final Color color;

  CategoryItem({required this.name, required this.icon, required this.color});
}

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // State untuk Dropdown Kategori
  CategoryItem? _selectedCategory;

  // Data Kategori Tagihan
  final List<CategoryItem> _billCategories = [
    CategoryItem(name: 'Tagihan', icon: Icons.lightbulb, color: Colors.brown),
    CategoryItem(name: 'Sewa/Cicilan', icon: Icons.home, color: Colors.indigo),
    CategoryItem(name: 'Internet', icon: Icons.wifi, color: Colors.teal),
    CategoryItem(name: 'Pendidikan', icon: Icons.school, color: Colors.blue),
    CategoryItem(name: 'Lainnya', icon: Icons.more_horiz, color: Colors.grey),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _billCategories.first; // Set default

    // --- DEMO PERMISSION ---
    // Minta izin notifikasi saat halaman dibuka.
    // Ini akan memunculkan pop-up "Allow Notifications?" di Android 13+
    NotificationService().requestPermissions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Fungsi untuk menampilkan Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateController.text.isNotEmpty
          ? DateTime.parse(_dateController.text.split('/').reversed.join())
          : now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryGreen,
              onPrimary: textColor,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      String formattedDate =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";

      setState(() {
        _dateController.text = formattedDate;
      });
    }
  }

  // --- WIDGET KUSTOM ---

  // 1. Header Kustom
  Widget _buildCustomHeader(String userName, String avatarUrl) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipPath(
        clipper: _SimpleCurveClipper(),
        child: Container(
          height: 150,
          color: primaryGreen,
          child: Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/avatar.jpg'),
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'Halo, $userName!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: textColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 2. Widget Input Form Kustom
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    IconData? suffixIcon,
    VoidCallback? onTap,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    bool isReadOnly = readOnly || onTap != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          keyboardType: keyboardType,
          style: const TextStyle(color: textColor),
          onTap: onTap,
          showCursor: !isReadOnly,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            filled: true,
            fillColor: accentGreen,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: primaryGreen, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: primaryGreen, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: primaryGreen, width: 2.0),
            ),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: primaryGreen)
                : null,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // 3. Widget Dropdown Kategori
  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: accentGreen,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: primaryGreen, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<CategoryItem>(
              isExpanded: true,
              value: _selectedCategory,
              hint: const Text("Pilih Kategori"),
              icon: const Icon(Icons.keyboard_arrow_down, color: primaryGreen),
              items: _billCategories.map((CategoryItem category) {
                return DropdownMenuItem<CategoryItem>(
                  value: category,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: category.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          category.icon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (CategoryItem? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: _buildCustomHeader('Wildan Adzkia', 'assets/avatar.jpg'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- KARTU FORMULIR GABUNGAN ---
            Card(
              color: primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // HEADER TEKS
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 20.0,
                    ),
                    child: Text(
                      'ADD NEW REMINDER',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  // FORM INPUT
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildInputField(
                          label: 'Nama Tagihan',
                          hint: 'Contoh: Internet IndiHome',
                          controller: _nameController,
                        ),
                        _buildInputField(
                          label: 'Jumlah',
                          hint: 'Contoh: 300000',
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          label: 'Tanggal Jatuh Tempo',
                          hint: 'Pilih Tanggal',
                          controller: _dateController,
                          suffixIcon: Icons.calendar_today,
                          onTap: () => _selectDate(context),
                          readOnly: true,
                        ),
                        _buildCategoryDropdown(),
                        _buildInputField(
                          label: 'Catatan',
                          hint: 'Opsional',
                          controller: _noteController,
                        ),
                        const SizedBox(height: 30),

                        // TOMBOL SIMPAN (DENGAN DEMO NOTIFIKASI)
                        ElevatedButton(
                          onPressed: () {
                            // 1. Validasi
                            if (_nameController.text.isEmpty ||
                                _amountController.text.isEmpty ||
                                _dateController.text.isEmpty ||
                                _selectedCategory == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Semua field wajib diisi!'),
                                ),
                              );
                              return;
                            }

                            // 2. Buat Objek Model
                            final newBill = BillModel(
                              name: _nameController.text,
                              amount: _amountController.text,
                              category: _selectedCategory!.name,
                              dueDate: _dateController.text,
                              status: 'Unpaid Bill', // Default status
                            );

                            // --- LOGIKA NOTIFIKASI DEMO ---
                            // Kita delay 2 detik biar terasa kayak "sistem lagi memproses"
                            // Lalu TING! Muncul notif.
                            Future.delayed(const Duration(seconds: 2), () {
                              NotificationService().showDemoNotification(
                                id:
                                    DateTime.now().millisecondsSinceEpoch ~/
                                    1000,
                                title: '🔔 Pengingat Tagihan Baru!',
                                body:
                                    'Jangan lupa bayar ${_nameController.text} sebesar Rp ${_amountController.text}. Jatuh tempo: ${_dateController.text}',
                              );
                            });
                            // ------------------------------

                            // 3. Pop kembali ke halaman sebelumnya
                            Navigator.pop(context, newBill);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: textColor,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Clipper untuk Header Lengkung
class _SimpleCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 20);
    var controlPoint = Offset(size.width / 2, size.height + 20);
    var endPoint = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_SimpleCurveClipper oldClipper) => false;
}
