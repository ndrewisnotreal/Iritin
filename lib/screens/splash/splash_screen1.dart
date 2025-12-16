import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:iritin/screens/splash/splash_screen2.dart';
import 'package:iritin/screens/dashboard/dashboard_screen.dart';

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({super.key});

  @override
  State<SplashScreen1> createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1> {
  @override
  void initState() {
    super.initState();

    // Timer 3 detik untuk loading logo
    Timer(const Duration(seconds: 3), () {
      // --- LOGIKA PINTAR DISINI ---

      // 1. Cek apakah ada user yang nyangkut (sedang login)
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // KASUS A: SUDAH LOGIN
        // Langsung masuk Dashboard (Skip Splash 2 & Login)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        // KASUS B: BELUM LOGIN / LOGOUT
        // Masuk ke SplashScreen 2 (Intro & Tombol Mulai)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SplashScreen2()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan UI SplashScreen 1 TETAP SAMA
    return Scaffold(
      backgroundColor: const Color(0xFFF9FEE6),
      body: Stack(
        children: [
          // Background Atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/splash_screen1.png',
              fit: BoxFit.cover,
            ),
          ),
          // Background Bawah
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/splash_screen2.png',
              fit: BoxFit.cover,
            ),
          ),
          // Logo Tengah
          Center(
            child: Image.asset(
              'assets/Logo3.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
