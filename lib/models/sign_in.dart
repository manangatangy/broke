import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scoped_model/scoped_model.dart';

enum AuthStatus {
  INIT,
  NOT_SIGNED_IN,
  SIGNED_IN,
}

/// A protocol for signing into firebase.
/// currently supports the google and email providers, and some common functions.
/// The sign in state is held in AuthStatus and the FirebaseUser.
/// Common:
/// isSignedIn => checks if previous signed in session is available, and updates authStatus/firebaseUser
/// signOut => signs out, updates authStatus/firebaseUser
/// Google:
/// First call signInWithGoogleSilently() and if it returns false, then initiate the interactive
/// process; signInWithGoogleInteractively() which may also return false if sign in didnt succeed.
/// Both the functions update authStatus/firebaseUser appropriately.
/// Email:
/// User may create new account using signUpWithEmail() and then sendEmailVerification(), after which
/// the user should complete the verification via the emailed link. The convenience function
/// resetEmailPassword() is also available to allow user the change password if it's forgotten.
/// These functions don't change authStatus/firebaseUser.
/// Use signInWithEmail() to sign in and return success/fail (also updating authStatus/firebaseUser).
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
    // The above throws PlatformException(failed_to_recover_auth, Failed attempt to recover
    // authentication, null) if user abandons account sign in attempt.  Should be caught by caller.
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
