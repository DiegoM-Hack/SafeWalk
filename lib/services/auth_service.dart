import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  User? get currentUser =>
      _auth.currentUser;

  Future<UserCredential> login({
    required String email,
    required String password,
  }) {

    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

  }

  Future<UserCredential> register({
    required String email,
    required String password,
  }) {

    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

  }

  Future<UserCredential> signInWithGoogle() async {

    final GoogleSignInAccount? googleUser =
        await GoogleSignIn().signIn();

    if(googleUser == null){
      throw Exception("Inicio cancelado");
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential =
        GoogleAuthProvider.credential(

      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,

    );

    return await _auth.signInWithCredential(
      credential,
    );

  }

  Future<void> logout() async {

    await GoogleSignIn().signOut();

    await _auth.signOut();

  }

  Future<void> resetPassword(String email){

    return _auth.sendPasswordResetEmail(
      email: email,
    );

  }

}