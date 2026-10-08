import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get changes => _auth.authStateChanges();
  User? get user => _auth.currentUser;

  Future<UserCredential> login(String email, String password) => _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<UserCredential> register(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    await cred.user?.updateDisplayName(name.trim());
    await cred.user?.reload();
    return cred;
  }

  Future<void> resetPassword(String email) => _auth.sendPasswordResetEmail(email: email.trim());

  Future<UserCredential> loginWithGoogle() async {
    final user = await GoogleSignIn().signIn();
    if (user == null) throw Exception('Google sign-in cancelled');
    final tokens = await user.authentication;
    final credential = GoogleAuthProvider.credential(accessToken: tokens.accessToken, idToken: tokens.idToken);
    return _auth.signInWithCredential(credential);
  }

  Future<void> logout() async {
    final usesGoogle = _auth.currentUser?.providerData
        .any((provider) => provider.providerId == 'google.com') ?? false;
    await _auth.signOut();
    if (usesGoogle) {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {
        // Firebase sign-out has succeeded; a stale Google session must not
        // leave the UI in the authenticated state.
      }
    }
  }
}
