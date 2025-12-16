import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  // Singleton pattern (biar satu instance dipake rame-rame)
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 1. Inisialisasi (Dipanggil saat aplikasi baru buka)
  Future<void> init() async {
    // Settingan Android (Gambar icon default)
    // Pastikan ada file 'app_icon' atau gunakan '@mipmap/ic_launcher' (icon default flutter)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Aksi kalau notifikasi diklik (bisa dikosongin dulu buat demo)
        print("Notifikasi diklik: ${response.payload}");
      },
    );
  }

  // 2. Minta Izin Notifikasi (Khusus Android 13+)
  Future<void> requestPermissions() async {
    // Cek apakah permission sudah diberikan
    var status = await Permission.notification.status;
    if (status.isDenied) {
      // Kalau belum, minta izin (Nanti muncul Popup "Allow Iritin to send notifications?")
      await Permission.notification.request();
    }
  }

  // 3. Tampilkan Notifikasi DEMO (Langsung Muncul)
  Future<void> showDemoNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'bill_channel_id', // ID Channel unik
          'Bill Reminders', // Nama Channel yang muncul di setting HP
          channelDescription: 'Notifikasi untuk pengingat tagihan',
          importance:
              Importance.max, // MAX biar muncul pop-up di atas layar (Heads Up)
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
