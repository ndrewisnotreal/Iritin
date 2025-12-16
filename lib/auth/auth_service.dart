import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Sign Up (Sekarang menerima 'name')
  Future<String?> signUp({
    required String email,
    required String password,
    required String name, // <--- Parameter baru
  }) async {
    try {
      // Buat akun
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update Nama Lengkap ke Profil Firebase
      User? user = result.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload(); // Refresh data user biar namanya langsung muncul
      }

      return null; // Berhasil
    } on FirebaseAuthException catch (e) {
      return e.message; // Gagal
    }
  }

  // 2. Sign In (Logika tetap sama)
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Berhasil
    } on FirebaseAuthException catch (e) {
      return e.message; // Gagal (Password salah / User ga ada)
    }
  }

  Future<String?> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Berhasil (null artinya tidak ada error)
    } on FirebaseAuthException catch (e) {
      return e.message; // Gagal (misal format email salah)
    } catch (e) {
      return "Terjadi kesalahan: $e";
    }
  }

  // 3. Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
