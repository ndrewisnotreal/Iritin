import 'package:flutter/material.dart';
import 'package:iritin/models/bill_provider.dart';
import 'package:iritin/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

const Color primaryGreen = Color(0xFFD1F333);
const Color textColor = Color(0xFF2E4053);

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
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  CategoryItem? _selectedCategory;
  DateTime? _selectedDateTime;
  TimeOfDay? _selectedTime;

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
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final prefs = await SharedPreferences.getInstance();
    bool isEnabled = prefs.getBool('pref_notification') ?? true;
    if (isEnabled) {
      NotificationService().requestPermissions();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryGreen,
              onPrimary: textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryGreen,
              onPrimary: textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _timeController.text = "$hour:$minute";
      });
    }
  }

  void _saveReminder() async {
    if (_nameController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _selectedDateTime == null ||
        _selectedTime == null ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field (termasuk jam) wajib diisi!'),
        ),
      );
      return;
    }

    final DateTime scheduledDateTime = DateTime(
      _selectedDateTime!.year,
      _selectedDateTime!.month,
      _selectedDateTime!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Notifikasi 5 menit sebelum
    final DateTime notificationTriggerTime = scheduledDateTime.subtract(
      const Duration(minutes: 5),
    );

    if (notificationTriggerTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Waktu pengingat (5 menit sebelum) sudah terlewat! Pilih waktu di masa depan.',
          ),
        ),
      );
      return;
    }

    // Buat ID unik untuk notifikasi
    int notifId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final newBill = BillModel(
      name: _nameController.text,
      amount: _amountController.text,
      category: _selectedCategory!.name,
      dueDate: "${_dateController.text} ${_timeController.text}",
      status: 'Unpaid Bill',
      notificationId: notifId, // Simpan ID Notifikasi
    );

    final prefs = await SharedPreferences.getInstance();
    bool isNotifEnabled = prefs.getBool('pref_notification') ?? true;

    if (isNotifEnabled) {
      await NotificationService().scheduleNotification(
        id: notifId,
        title: '🔔 Ingat Bayar Tagihan!',
        body:
            '5 Menit lagi waktu bayar ${_nameController.text} sebesar Rp ${_amountController.text}.',
        scheduledTime: notificationTriggerTime,
      );
    }

    if (!mounted) return;
    Navigator.pop(context, newBill);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: primaryGreen,
              padding: const EdgeInsets.only(bottom: 40),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: textColor),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "Add Reminder",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "DETAIL TAGIHAN",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInputLabel("Nama Tagihan"),
                      _buildTextField(
                        controller: _nameController,
                        hint: "Contoh: WiFi Rumah",
                        icon: Icons.label_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildInputLabel("Jumlah Tagihan"),
                      _buildTextField(
                        controller: _amountController,
                        hint: "Rp 0",
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildInputLabel("Kategori"),
                      _buildCategoryDropdown(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _buildInputLabel("Jatuh Tempo"),
                                _buildTextField(
                                  controller: _dateController,
                                  hint: "Tgl",
                                  icon: Icons.calendar_today,
                                  readOnly: true,
                                  onTap: () => _selectDate(context),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                _buildInputLabel("Pukul (Jam)"),
                                _buildTextField(
                                  controller: _timeController,
                                  hint: "Jam",
                                  icon: Icons.access_time,
                                  readOnly: true,
                                  onTap: () => _selectTime(context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInputLabel("Catatan (Opsional)"),
                      _buildTextField(
                        controller: _noteController,
                        hint: "Tambahkan detail...",
                        icon: Icons.notes,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: textColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _saveReminder,
                          child: const Text(
                            "Simpan & Pasang Timer",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        style: const TextStyle(fontWeight: FontWeight.w600, color: textColor),
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CategoryItem>(
          isExpanded: true,
          value: _selectedCategory,
          hint: const Text("Pilih Kategori"),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          items: _billCategories.map((CategoryItem category) {
            return DropdownMenuItem<CategoryItem>(
              value: category,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Icon(category.icon, color: category.color, size: 18),
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
          onChanged: (CategoryItem? newValue) =>
              setState(() => _selectedCategory = newValue),
        ),
      ),
    );
  }
}