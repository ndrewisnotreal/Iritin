import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iritin/firebase_options.dart';
import 'package:iritin/providers/dashboard_provider.dart';
import 'package:iritin/providers/transaction_provider.dart';
import 'package:iritin/models/bill_provider.dart';
import 'package:iritin/models/account_provider.dart';
import 'package:iritin/services/notification_service.dart';
import 'package:iritin/screens/dashboard/dashboard_screen.dart';
import 'package:iritin/screens/auth/login_screen.dart';
import 'package:iritin/screens/splash/splash_screen1.dart'; // Import Splash 1

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BillProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Iritin',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFCCFF00)),
      ),
      // MULAILAH DARI SPLASH SCREEN 1
      home: const SplashScreen1(),
    );
  }
}

// Widget Baru: Gerbang Pengecekan Login
// Ini akan dipanggil setelah user klik "Mulai" di Splash Screen 2
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const DashboardScreen(); // Sudah Login
        }
        return const LoginScreen(); // Belum Login
      },
    );
  }
}
