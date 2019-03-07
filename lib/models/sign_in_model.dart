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
  Future<bool> checkForSignIn() async {
    print("SignInModel.checkGoogleSignIn");
    FirebaseUser user = await firebaseAuth.currentUser();
    if (checkUserAndSetStatus("checkForSignIn.firebaseAuth.currentUser", user)) {
      return true;
    }
    GoogleSignInAccount googleAccount = await _getGoogleSignInAccount(googleSignIn);
    if (googleAccount == null) {
      return checkUserAndSetStatus("checkForSignIn.no-existing-sign-in", null);
    }
    // User is already signed in to google, complete the firebase sign in.
    return await signInWithGoogle(googleAccount);
  }

  /// Starts the interactive sign-in to google (unless already signed in to
  /// google, indicate by non-null parameter)
  /// and then signs in to firebase, using the google account.
  Future<bool> signInWithGoogle(GoogleSignInAccount googleAccount) async {
    if (googleAccount == null) {
      // This bit is interactive.
      googleAccount = await googleSignIn.signIn();
    }
    FirebaseUser user;
    if (googleAccount != null) {
      user = await _googleSignIntoFirebase(googleAccount);
    }
    return checkUserAndSetStatus("signInWithGoogle", user);
  }

  /// If there is a currently signed in account, return it.
  /// Else try to sign in (without interaction) to the previous signed
  /// in user and return that account.
  Future<GoogleSignInAccount> _getGoogleSignInAccount(GoogleSignIn googleSignIn) async {
    // Is the user already signed in?
    GoogleSignInAccount account = googleSignIn.currentUser;
    print("SignInModel.googleSignIn.currentUser => $account");
    // Try to sign in the previous user:
    if (account == null) {
      account = await googleSignIn.signInSilently();
      print("SignInModel.signInSilently => $account");
    }
    return account;
  }

  Future<FirebaseUser> _googleSignIntoFirebase(GoogleSignInAccount googleSignInAccount) async {
    GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;
    return await firebaseAuth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    //TODO catch PlatformException(exception, The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section. [ The identity provider configuration is disabled. ], null)
  }

  Future<bool> checkForSignInX(bool signedIn) async {
    return Future<bool>.delayed(Duration(seconds: 5), () {
      print("SignInModel.checkForSignInX signedIn => $signedIn");
      authStatus = signedIn ? AuthStatus.SIGNED_IN : AuthStatus.NOT_SIGNED_IN;
      return signedIn;
    });
  }
  Future<bool> signInWithGoogleX(bool signedIn, GoogleSignInAccount _) async {
    return Future<bool>.delayed(Duration(seconds: 5), () {
      print("SignInModel.signInWithGoogleX signedIn => $signedIn");
      authStatus = signedIn ? AuthStatus.SIGNED_IN : AuthStatus.NOT_SIGNED_IN;
      return signedIn;
    });
  }

  //---------------------------------------------------------------------------------------

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
    return checkUserAndSetStatus("signInWithEmail", user);
  }

  Future<FirebaseUser> signUpWithEmailX(String email, String password) async {
    return Future<FirebaseUser>.delayed(Duration(seconds: 5), () {
      return null;
    });
  }

  Future<bool> signInWithEmailX(bool signedIn, String email, String password) async {
    return Future<bool>.delayed(Duration(seconds: 5), () {
      print("SignInModel.signInWithEmailX signedIn => $signedIn");
      authStatus = signedIn ? AuthStatus.SIGNED_IN : AuthStatus.NOT_SIGNED_IN;
      return signedIn;
    });
  }

  //---------------------------------------------------------------------------------------

  /// Check the user and if ok, store it and set SIGNED_IN,
  /// else set NOT_SIGNED_IN.  Return true if signed in.
  bool checkUserAndSetStatus(String label, FirebaseUser user) {
    String userId = user?.uid;
    if (userId.length > 0 && userId != null) {
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
