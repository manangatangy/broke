

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Protocol for email-sign-in;
/// 1. check if already signed in by calling getCurrentUser
/// 2. if not logged in then can call either signUp or signIn
/// 3. signUp should be followed by call to sendEmailVerification
/// which should be advised to the user (to check their email) and
/// then user asked to signIn with newly created credentials
/// 4. signIn as usual
/// Protocol for google-sign-in;
///
///
/// With the FirebaseUser returned from getCurrentUser, there is a UserInfo list
/// each element of has a providerId, displayName, photoUrl.
///
class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return user.uid;
  }

  Future<String> signUp(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

  Future<List<String>> fetch(String email) async {
    List<String> providers = await _firebaseAuth.fetchProvidersForEmail(email: email);
    return providers;
  }

}

/// If there is a currently signed in account, return it.
/// Else try to sign in (without interaction) to the previous signed
/// in user and return that account.
Future<GoogleSignInAccount> getGoogleSignInAccount(GoogleSignIn googleSignIn) async {
  // Is the user already signed in?
  GoogleSignInAccount account = googleSignIn.currentUser;
  // Try to sign in the previous user:
  if (account == null) {
    account = await googleSignIn.signInSilently();
  }
  return account;
}

Future<FirebaseUser> googleSignIntoFirebase(GoogleSignInAccount googleSignInAccount) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;
  return await _auth.signInWithGoogle(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
}
