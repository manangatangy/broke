import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scoped_model/scoped_model.dart';

/// state               transition
/// home:INIT           push(login)
/// login:INIT          init-user -> SIGNED_IN/NOT_SIGNED_IN
/// login:SIGNED_IN     pop(back to home, SIGNED_IN)
/// home:SIGNED_IN      show-home-screen
///
/// login:NOT_SIGNED_IN show-sign-in-options
/// login:click-back    pop(back to home, NOT_SIGNED_IN)
/// home:NOT_SIGNED_IN  pop(exit?)
///
/// login:click-email   push(email)
/// email:signed-in-ok  -> SIGNED_IN, pop(back to login)
/// login:signed-in-ok  pop(back to home)
/// email:click-back    pop(back to login)
///
enum AuthStatus {
  INIT,     // Signals; home:push(login), login:start-init
//  UNKNOWN,
  NOT_SIGNED_IN,
  SIGNED_IN,
}

class SignInModel extends Model {

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  AuthStatus authStatus = AuthStatus.INIT;
  FirebaseUser firebaseUser;

  static SignInModel of(BuildContext context) => ScopedModel.of<SignInModel>(context);

  /// First checks if there is a current user.  If not, then
  /// checks if user is already signed in to google, or can be signed
  /// in (silently), and then signs into using google.  Otherwise just turns
  /// off the loading spinner.
  Future<AuthStatus> init() async {
    print("SignInModel.init");
    FirebaseUser user = await firebaseAuth.currentUser();
    print("SignInModel.init:currentUser $user");
    if (user?.uid != null) {
      authStatus = AuthStatus.SIGNED_IN;
      firebaseUser = user;
      print("SignInModel.init:signed in via email $firebaseUser");
    } else {
      GoogleSignInAccount googleAccount = await _getGoogleSignInAccount(googleSignIn);
      print("SignInModel.init:getGoogleSignInAccount $googleAccount");
      if (googleAccount != null) {
        // User is already signed in to google, complete the firebase sign in.
        FirebaseUser user = await _googleSignIntoFirebase(googleAccount);
        authStatus = AuthStatus.SIGNED_IN;
        firebaseUser = user;
        print("SignInModel.init:signed in via google $firebaseUser");
      } else {
        authStatus = AuthStatus.NOT_SIGNED_IN;
        print("SignInModel.init:not signed in");
      }
    }
    notifyListeners();
    return authStatus;
  }

  /// Starts the interactive sign-in to google (unless already signed in)
  /// and then signs in to firebase, using the google account.
  Future<FirebaseUser> signInWithGoogle() async {
    GoogleSignInAccount googleAccount = await googleSignIn.signIn();
    if (googleAccount != null) {
      FirebaseUser user = await _googleSignIntoFirebase(googleAccount);
      authStatus = AuthStatus.SIGNED_IN;
      firebaseUser = user;
      print("SignInModel.signInWithGoogle:signed in via google $firebaseUser");
      notifyListeners();
    }
    return firebaseUser;
  }

  /// If there is a currently signed in account, return it.
  /// Else try to sign in (without interaction) to the previous signed
  /// in user and return that account.
  Future<GoogleSignInAccount> _getGoogleSignInAccount(GoogleSignIn googleSignIn) async {
    // Is the user already signed in?
    GoogleSignInAccount account = googleSignIn.currentUser;
    // Try to sign in the previous user:
    if (account == null) {
      account = await googleSignIn.signInSilently();
    }
    return account;
  }

  Future<FirebaseUser> _googleSignIntoFirebase(GoogleSignInAccount googleSignInAccount) async {
    GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;
    return await firebaseAuth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  Future<FirebaseUser> signUpWithEmail(String email, String password) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  String sendEmailVerification(FirebaseUser user) {
    user.sendEmailVerification();
    return user?.uid;   // Convenience.
  }

  Future<FirebaseUser> signInWithEmail(String email, String password) async {
    return await firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  void haveSignedIn(FirebaseUser user) {
    authStatus = AuthStatus.SIGNED_IN;
    firebaseUser = user;
    print("SignInModel.signedIn $firebaseUser");
//    notifyListeners();
  }

}
