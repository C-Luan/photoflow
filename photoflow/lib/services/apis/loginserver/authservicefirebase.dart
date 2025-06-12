import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:photoflow/services/apis/loginserver/authservice.dart';

class AuthServiceFirebase {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _httpClient = Dio(); // Troque pela URL real

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Login cancelado.');

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    final String? idToken = await userCredential.user?.getIdToken();
    if (idToken == null) throw Exception('Token inválido.');

    final response = await AuthserviceVps().authService(idToken);

    return userCredential;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // 🔹 Login com e-mail e senha
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String? idToken = await userCredential.user?.getIdToken();
      if (idToken == null) throw Exception('Token inválido.');

      final response = await AuthserviceVps().authService(idToken);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception('Erro ao fazer login: ${e.message}');
    }
  }

  User? get currentUser => _auth.currentUser;
}
