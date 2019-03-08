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

/// 
/// There are two protocols for the sign-in.
/// The first consists of three methods;
/// 1. check for existing sign in and 
class SignInModel extends Model {

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  AuthStatus authStatus = AuthStatus.INIT;
  FirebaseUser firebaseUser;

  static SignInModel of(BuildContext context) => ScopedModel.of<SignInModel>(context);

  /// This function returns true if currently signed in (which may be from
  /// a previous session), also setting user and authStatus.
  Future<bool> isSignedIn() async {
    print("SignInModel.isSignedIn");
    FirebaseUser user = await firebaseAuth.currentUser();
    return _checkUserAndSetStatus("isSignedIn.firebaseAuth.currentUser", user);
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
    firebaseUser = null;
    authStatus = AuthStatus.NOT_SIGNED_IN;
  }

//  Future<void> signOutX() {
//    return Future<void>.delayed(Duration(seconds: 5), () {
//      firebaseUser = null;
//      authStatus = AuthStatus.NOT_SIGNED_IN;
//    });
//  }

  /// If there is a currently signed in account, return it.
  /// Else try to sign in (without interaction) to the previous signed
  /// in user and return that account.

  //----------------------------- google-sign-in ----------------------------------------------------------

  /// If there is a current google account or we can silently sign into it,
  /// then use it to sign into firebase and return true.
  Future<bool> signInWithGoogleSilently() async {
    // Is the user already signed in?
    GoogleSignInAccount account = googleSignIn.currentUser;
    print("SignInModel.signInWithGoogleSilently googleSignIn.currentUser() => $account");
    // Try to sign in the previous user:
    if (account == null) {
      account = await googleSignIn.signInSilently();
      print("SignInModel.googleSignIn.signInSilently => $account");
    }
    return await _signInWithGoogle(account);
  }

  /// Starts the interactive sign-in to google (unless already signed in to
  /// google, indicate by non-null parameter)
  /// and then signs in to firebase, using the google account.
  Future<bool> signInWithGoogleInteractively() async {
    // This bit is interactive.
    GoogleSignInAccount account = await googleSignIn.signIn();
    print("SignInModel.signInWithGoogleInteractively googleSignIn.signIn() => $account");
    return _signInWithGoogle(account);
  }

  Future<bool> _signInWithGoogle(GoogleSignInAccount account) async {
    FirebaseUser user;
    if (account == null) {
      // Explicit message.
      return _checkUserAndSetStatus("no-google-account", null);
    }
    GoogleSignInAuthentication googleAuth = await account.authentication;
    // The above throws PlatformException(failed_to_recover_auth, Failed attempt to recover authentication, null)
    // if user abandons the account sign in attempt.
    user = await firebaseAuth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _checkUserAndSetStatus("_signInWithGoogle", user);
  }

  //TODO catch PlatformException(exception, The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section. [ The identity provider configuration is disabled. ], null)

//  Future<bool> checkForSignInX(bool signedIn) async {
//    return Future<bool>.delayed(Duration(seconds: 5), () {
//      print("SignInModel.checkForSignInX signedIn => $signedIn");
//      authStatus = signedIn ? AuthStatus.SIGNED_IN : AuthStatus.NOT_SIGNED_IN;
//      return signedIn;
//    });
//  }
//  Future<bool> signInWithGoogleX(bool signedIn, GoogleSignInAccount _) async {
//    return Future<bool>.delayed(Duration(seconds: 5), () {
//      print("SignInModel.signInWithGoogleX signedIn => $signedIn");
//      authStatus = signedIn ? AuthStatus.SIGNED_IN : AuthStatus.NOT_SIGNED_IN;
//      return signedIn;
//    });
//  }

  //------------------------------- email-sign-in --------------------------------------------------------

  Future<FirebaseUser> signUpWithEmail(String email, String password) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  String sendEmailVerification(FirebaseUser user) {
    if (user != null) {
      user.sendEmailVerification();
    }
    return user?.uid;   // Convenience.
  }

  Future<bool> signInWithEmail(String email, String password) async {
    FirebaseUser user =  await firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return _checkUserAndSetStatus("signInWithEmail", user);
  }

  Future<void> resetEmailPassword(String email) async {
    return await firebaseAuth.sendPasswordResetEmail(email: email);
  }

//  Future<FirebaseUser> signUpWithEmailX(String email, String password) async {
//    return Future<FirebaseUser>.delayed(Duration(seconds: 5), () {
//      return null;
//    });
//  }
//
//  Future<bool> signInWithEmailX(bool signedIn, String email, String password) async {
//    return Future<bool>.delayed(Duration(seconds: 5), () {
//      print("SignInModel.signInWithEmailX signedIn => $signedIn");
//      authStatus = signedIn ? AuthStatus.SIGNED_IN : AuthStatus.NOT_SIGNED_IN;
//      return signedIn;
//    });
//  }

  //---------------------------------------------------------------------------------------

  /// Check the user and if ok, store it and set SIGNED_IN,
  /// else set NOT_SIGNED_IN.  Return true if signed in.
  bool _checkUserAndSetStatus(String label, FirebaseUser user) {
    String userId = user?.uid;
    if (userId != null && userId.length > 0) {
      firebaseUser = user;
      authStatus = AuthStatus.SIGNED_IN;
    } else {
      firebaseUser = null;
      authStatus = AuthStatus.NOT_SIGNED_IN;
    }
    print('SignInModel.$label user => $user, status => $authStatus}');
    return (authStatus == AuthStatus.SIGNED_IN);

  }
}
