import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// FIX KONFLIK 1: Import model yang benar
import 'package:iritin/models/bill_model.dart';
// FIX KONFLIK 2: Sembunyikan BillModel yang ada di provider
import 'package:iritin/providers/bill_provider.dart' hide BillModel; 
import 'package:iritin/services/notification_service.dart';

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
  final TextEditingController _timeController = TextEditingController(); // TAMBAHAN: Controller Jam

  CategoryItem? _selectedCategory;
  
  // Variabel Helper
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime; // TAMBAHAN: Variabel Jam

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
    _selectedCategory = _billCategories.first;
    NotificationService().requestPermissions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  // Fungsi untuk menampilkan Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: primaryGreen, onPrimary: textColor),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }
  
  // TAMBAHAN: Fungsi untuk menampilkan Time Picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? now,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: primaryGreen, onPrimary: textColor),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        // Format jam HH:mm
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _timeController.text = "$hour:$minute";
      });
    }
  }

  // --- WIDGET KUSTOM (UI LAMA ANDA) ---
  Widget _buildCustomHeader(String userName, String avatarUrl) {
    return AppBar(automaticallyImplyLeading: false, backgroundColor: Colors.transparent, flexibleSpace: ClipPath(clipper: _SimpleCurveClipper(), child: Container(height: 150, color: primaryGreen, child: Padding(padding: const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [const CircleAvatar(radius: 25, backgroundImage: AssetImage('assets/avatar.jpg'), backgroundColor: Colors.white), const SizedBox(width: 15), Text('Halo, $userName!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor))]), IconButton(icon: const Icon(Icons.arrow_back, color: textColor), onPressed: () => Navigator.pop(context))])))));
  }

  Widget _buildInputField({required String label, required String hint, required TextEditingController controller, IconData? suffixIcon, VoidCallback? onTap, bool readOnly = false, TextInputType keyboardType = TextInputType.text}) {
    bool isReadOnly = readOnly || onTap != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller, readOnly: isReadOnly, keyboardType: keyboardType, style: const TextStyle(color: textColor), onTap: onTap, showCursor: !isReadOnly,
          decoration: InputDecoration(
            hintText: hint, hintStyle: TextStyle(color: textColor.withOpacity(0.6)), contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            filled: true, fillColor: accentGreen,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: primaryGreen, width: 1.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: primaryGreen, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: primaryGreen, width: 2.0)),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: primaryGreen) : null,
          ),
        ),
        const SizedBox(height: 20),
    ]);
  }

  Widget _buildCategoryDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Kategori', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(color: accentGreen, borderRadius: BorderRadius.circular(15), border: Border.all(color: primaryGreen, width: 1.5)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<CategoryItem>(
              isExpanded: true, value: _selectedCategory,
              hint: const Text("Pilih Kategori"), icon: const Icon(Icons.keyboard_arrow_down, color: primaryGreen),
              items: _billCategories.map((CategoryItem category) {
                return DropdownMenuItem<CategoryItem>(
                  value: category,
                  child: Row(children: [
                      Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: category.color, borderRadius: BorderRadius.circular(4)),
                        child: Icon(category.icon, color: Colors.white, size: 20)),
                      const SizedBox(width: 12),
                      Text(category.name, style: const TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                  ]),
                );
              }).toList(),
              onChanged: (CategoryItem? newValue) { setState(() { _selectedCategory = newValue; }); },
            ),
          ),
        ),
        const SizedBox(height: 20),
    ]);
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
            Card(
              color: primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              elevation: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                    child: Text('ADD NEW REMINDER', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor, letterSpacing: 1.5)),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                    child: Column(
                      children: [
                        _buildInputField(label: 'Nama Tagihan', hint: 'Contoh: Internet IndiHome', controller: _nameController),
                        _buildInputField(label: 'Jumlah', hint: 'Contoh: 300000', controller: _amountController, keyboardType: TextInputType.number),
                        
                        // INJECTION UI: Tanggal dan Jam
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                label: 'Tanggal Jatuh Tempo',
                                hint: 'Pilih Tanggal',
                                controller: _dateController,
                                suffixIcon: Icons.calendar_today,
                                onTap: () => _selectDate(context),
                                readOnly: true,
                              ),
                            ),
                            const SizedBox(width: 10), // Jarak
                            Expanded(
                              child: _buildInputField(
                                label: 'Jam',
                                hint: 'Pilih Jam',
                                controller: _timeController,
                                suffixIcon: Icons.access_time, // Icon Jam
                                onTap: () => _selectTime(context), // Time Picker
                                readOnly: true,
                              ),
                            ),
                          ],
                        ),

                        _buildCategoryDropdown(),
                        _buildInputField(label: 'Catatan', hint: 'Opsional', controller: _noteController),
                        const SizedBox(height: 30),

                        // TOMBOL SIMPAN (LOGIKA BARU JADWAL)
                        ElevatedButton(
                          onPressed: () {
                            // 1. Validasi
                            if (_nameController.text.isEmpty ||
                                _amountController.text.isEmpty ||
                                _dateController.text.isEmpty ||
                                _timeController.text.isEmpty || // Cek Jam
                                _selectedCategory == null ||
                                _selectedDate == null ||
                                _selectedTime == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Semua field wajib diisi!')),
                              );
                              return;
                            }

                            // 2. Gabungkan Tanggal + Jam menjadi Deadline
                            final DateTime deadline = DateTime(
                              _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
                              _selectedTime!.hour, _selectedTime!.minute,
                            );

                            // 3. Hitung Waktu Notifikasi (5 MENIT SEBELUM DEADLINE)
                            final DateTime notificationTime = deadline.subtract(const Duration(minutes: 5));

                            // Cek apakah notifikasi sudah lewat
                            if (notificationTime.isBefore(DateTime.now())) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Waktu pengingat (5 menit sebelum) sudah lewat!')),
                                );
                                return;
                            }

                            // 4. Jadwalkan Notifikasi (Menggunakan Future.delayed dari Service)
                            final int notifId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                            NotificationService().scheduleNotification(
                              id: notifId,
                              title: '🔔 Pengingat: ${_nameController.text}',
                              body: 'Bayar Rp ${_amountController.text}. Deadline: ${_dateController.text} ${_timeController.text}',
                              scheduledDate: notificationTime,
                            );

                            // 5. Buat Objek Model & Kembali
                            final fullDateString = "${_dateController.text} ${_timeController.text}";
                            final newBill = BillModel(
                              name: _nameController.text,
                              amount: _amountController.text,
                              category: _selectedCategory!.name,
                              dueDate: fullDateString, 
                              status: 'Unpaid Bill',
                              notes: _noteController.text,
                            );

                            Navigator.pop(context, newBill);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: textColor,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 5,
                          ),
                          child: const Text('Simpan & Jadwalkan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

class _SimpleCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path(); path.lineTo(0, size.height - 20);
    var controlPoint = Offset(size.width / 2, size.height + 20);
    var endPoint = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, 0); path.close(); return path;
  }
  @override
  bool shouldReclip(_SimpleCurveClipper oldClipper) => false;
}