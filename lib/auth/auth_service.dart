import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <--- JANGAN LUPA IMPORT INI

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // <--- Instance Firestore

  // 1. Sign Up (Email & Password) + Simpan Data ke Firestore
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // A. Buat Akun di Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // B. Update Nama di Profil Auth (Opsional tapi bagus)
        await user.updateDisplayName(name);
        await user.reload();
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return null; // Berhasil
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      return e.toString();
    }
  }

  // 2. Sign In (Email & Password)
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Berhasil
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  // 3. Sign In With Google + Simpan Data ke Firestore
  Future<String?> signInWithGoogle() async {
    try {
      // A. Buka Pop-up Pilih Akun
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return "cancel";

      // B. Ambil Token
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // C. Buat Kredensial
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // D. Masuk ke Firebase
      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      // E. CEK & SIMPAN DATA KE FIRESTORE (JIKA USER BARU)
      if (user != null) {
        // Cek apakah data user sudah ada di Firestore?
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // Jika belum ada (User Baru Login Google), simpan datanya
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': user.displayName ?? "No Name",
            'email': user.email,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      return e.toString();
    }
  }

  // 4. Reset Password
  Future<String?> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan: $e";
    }
  }

  // 5. Sign Out
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  User? get currentUser => _auth.currentUser;
}
