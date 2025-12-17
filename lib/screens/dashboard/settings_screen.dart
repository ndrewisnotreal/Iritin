import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <--- IMPORT WAJIB
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:iritin/auth/auth_service.dart';
import 'package:iritin/screens/auth/login_screen.dart';

// --- IMPORT PROVIDER (Sesuaikan path jika beda) ---
import 'package:iritin/providers/transaction_provider.dart';
import 'package:iritin/models/account_provider.dart';

// --- WARNA & KONSTANTA ---
const Color primaryGreen = Color(0xFFD1F333);
const Color textColor = Color(0xFF2E4053);
const Color dangerColor = Color(0xFFFF4C4C);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // STATE PREFERENSI (Default True/False)
  bool _isNotificationEnabled = true;

  bool _isLoading = false;
  String? _localImagePath;
  User? get currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadLocalImage();
    _loadPreferences(); // Load status switch saat halaman dibuka
  }

  // --- FUNGSI 0: LOAD DATA DARI MEMORI HP ---
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isNotificationEnabled = prefs.getBool('pref_notification') ?? true;
    });
  }

  Future<void> _loadLocalImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _localImagePath = prefs.getString('profile_image_${currentUser?.uid}');
    });
  }

  // --- FUNGSI SIMPAN PREFERENSI ---
  Future<void> _toggleNotification(bool value) async {
    setState(() => _isNotificationEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_notification', value);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? "Notifikasi Diaktifkan" : "Notifikasi Dinonaktifkan",
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<bool> _requestGalleryPermission() async {
    Permission permission;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        permission = Permission.photos;
      } else {
        permission = Permission.storage;
      }
    } else {
      permission = Permission.photos;
    }

    var status = await permission.status;
    if (status.isDenied) {
      status = await permission.request();
    }
    if (status.isPermanentlyDenied) {
      if (!mounted) return false;
      _showOpenSettingsDialog();
      return false;
    }
    return status.isGranted || status.isLimited;
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Izin Diperlukan"),
        content: const Text("Silakan izinkan akses foto di pengaturan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text("Buka Pengaturan"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndSaveImageLocal() async {
    final hasPermission = await _requestGalleryPermission();
    if (!hasPermission) return;

    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() => _isLoading = true);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_${currentUser?.uid}', image.path);

        setState(() {
          _localImagePath = image.path;
          _isLoading = false;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto profil berhasil diperbarui!")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    }
  }

  // --- LOGOUT YANG SUDAH DIPERBAIKI ---
  Future<void> _handleLogout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Konfirmasi Keluar"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Keluar", style: TextStyle(color: dangerColor)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // 1. BERSIHKAN DATA PROVIDER (Agar User Baru Tidak Lihat Data Lama)
      if (mounted) {
        context.read<TransactionProvider>().resetData();
        context.read<AccountProvider>().resetData();
      }

      // 2. LOGOUT DARI FIREBASE
      await AuthService().signOut();

      // 3. NAVIGASI KE LOGIN
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // ... (SISA KODE EDIT PROFILE & CHANGE PASSWORD TETAP SAMA) ...

  void _showEditProfileDialog() {
    final TextEditingController nameController = TextEditingController(
      text: currentUser?.displayName,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Ganti Nama"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: "Nama Lengkap",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: textColor,
            ),
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                try {
                  await currentUser?.updateDisplayName(nameController.text);
                  await currentUser?.reload();
                  if (!mounted) return;
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nama berhasil diubah!")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
                }
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: primaryGreen, size: 60),
            const SizedBox(height: 16),
            const Text(
              "Password Sukses diganti",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Silakan login kembali dengan password baru.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: textColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "OK",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final TextEditingController oldPassController = TextEditingController();
    final TextEditingController newPassController = TextEditingController();
    bool isObscure = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text("Ganti Kata Sandi"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Demi keamanan, masukkan password lama Anda sebelum mengganti ke yang baru.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: oldPassController,
                    obscureText: isObscure,
                    decoration: InputDecoration(
                      labelText: "Password Lama",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isObscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setStateDialog(() => isObscure = !isObscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPassController,
                    obscureText: isObscure,
                    decoration: const InputDecoration(
                      labelText: "Password Baru",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: textColor,
                  ),
                  onPressed: () async {
                    String oldPass = oldPassController.text;
                    String newPass = newPassController.text;

                    if (oldPass.isEmpty || newPass.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Semua kolom harus diisi"),
                        ),
                      );
                      return;
                    }
                    if (newPass.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Password baru min. 6 karakter"),
                        ),
                      );
                      return;
                    }

                    try {
                      String email = currentUser!.email!;
                      AuthCredential credential = EmailAuthProvider.credential(
                        email: email,
                        password: oldPass,
                      );
                      await currentUser!.reauthenticateWithCredential(
                        credential,
                      );
                      await currentUser!.updatePassword(newPass);
                      if (!mounted) return;
                      Navigator.pop(context);
                      _showSuccessDialog();
                    } on FirebaseAuthException catch (e) {
                      String message = "Gagal mengganti password";
                      if (e.code == 'wrong-password') {
                        message = "Password lama salah!";
                      } else if (e.code == 'weak-password') {
                        message = "Password baru terlalu lemah";
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: dangerColor,
                        ),
                      );
                    }
                  },
                  child: const Text("Ganti Password"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    final user = currentUser;
    String name = user?.displayName ?? "Pengguna";
    String email = user?.email ?? "email@iritin.com";

    ImageProvider? backgroundImage;
    if (_localImagePath != null) {
      backgroundImage = FileImage(File(_localImagePath!));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 40),
      decoration: const BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickAndSaveImageLocal,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage: backgroundImage,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : (_localImagePath == null
                              ? const Icon(
                                  Icons.person,
                                  size: 35,
                                  color: Colors.grey,
                                )
                              : null),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: textColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _showEditProfileDialog,
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  "Akun",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                _buildSettingTile(
                  icon: Icons.person_outline,
                  title: "Ganti Foto Profil (Lokal)",
                  onTap: _pickAndSaveImageLocal,
                ),
                _buildSettingTile(
                  icon: Icons.lock_outline,
                  title: "Ganti Kata Sandi",
                  onTap: _showChangePasswordDialog,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Preferensi",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                _buildSettingTile(
                  icon: Icons.notifications_outlined,
                  title: "Notifikasi",
                  trailing: Switch(
                    value: _isNotificationEnabled,
                    activeColor: primaryGreen,
                    onChanged: (val) => _toggleNotification(val),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _handleLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFECEC),
                      foregroundColor: dangerColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Keluar Akun",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Icon(icon, color: textColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                ),
                if (trailing != null)
                  trailing
                else
                  const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
