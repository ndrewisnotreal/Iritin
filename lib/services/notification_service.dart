import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; 
// HAPUS IMPORT TIMEZONE
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 1. Inisialisasi (TIDAK PERLU INIT TIMEZONE LAGI)
  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        print("Notifikasi diklik: ${response.payload}");
      },
    );
  }

  // 2. Minta Izin Notifikasi & Alarm
  Future<void> requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    // HAPUS Izin Alarm Akurat, karena kita tidak pakai zonedSchedule lagi
    // if (await Permission.scheduleExactAlarm.isDenied) {
    //   await Permission.scheduleExactAlarm.request();
    // }
  }

  // 3. FUNGSI BARU: JADWALKAN MENGGUNAKAN FUTURE.DELAYED (COUNTDOWN)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final now = DateTime.now();
    final difference = scheduledDate.difference(now);

    if (difference.isNegative) {
      print("Waktu notifikasi sudah lewat.");
      return;
    }
    
    // Konfigurasi Notifikasi
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'bill_channel_scheduled',
      'Bill Reminders Scheduled',
      channelDescription: 'Notifikasi Terjadwal',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      fullScreenIntent: true,
      playSound: true,
      enableVibration: true,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);


    print("✅ COUNTDOWN Dimulai: Alarm dijadwalkan dalam ${difference.inMinutes} menit lagi.");

    // Gunakan Future.delayed untuk menjalankan showDemoNotification setelah durasi habis
    Future.delayed(difference, () {
      showDemoNotification(id: id, title: title, body: body);
      print("🔔 Notifikasi Countdown Berbunyi!");
    });
  }

  // 4. Fungsi Demo Lama (Digunakan oleh scheduleNotification yang baru)
  Future<void> showDemoNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'bill_channel_id',
      'Bill Reminders',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(id, title, body, details);
  }
}