

import 'package:broke/widgets/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scoped_model/scoped_model.dart';

void main2() => runApp(MyApp());

enum AuthStatus { INIT, UNKNOWN, NOT_SIGNED_IN, SIGNED_IN, }

class SignInModel extends Model {

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  AuthStatus authStatus = AuthStatus.INIT;
  FirebaseUser firebaseUser;

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

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // First, create a `ScopedModel` widget. This will provide
    // the `model` to the children that request it.
    return ScopedModel<SignInModel>(
        model: SignInModel(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Recipes',
          theme: buildTheme(),
          initialRoute: "login",
          routes: {
            // If you're using navigation routes, Flutter needs a base route.
            // We're going to change this route once we're ready with
            // implementation of HomeScreen.
            '/': (context) => Page1(),
            'login': (context) => PageLogin(),
          },
        )
    );
  }
}

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("page 1 Route"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}

class PageLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("page 2 Route"),
      ),
      body: Center(
        child: ScopedModelDescendant<SignInModel>(
          builder: (context, child, model) {
            print("PageLogin.build: ${model.authStatus}");
            switch (model.authStatus) {
              case AuthStatus.INIT:
                model.init();
                return CircularProgressIndicator();
                break;
              case AuthStatus.UNKNOWN:
                return Text("UNKNOWN");
                break;
              case AuthStatus.NOT_SIGNED_IN:
                return RaisedButton(
                    child: Text("NOT SIGNED IN, click to sign in with google"),
                    onPressed: () {
                      model.signInWithGoogle();
                    },
                  );
                break;
              case AuthStatus.SIGNED_IN:
                Navigator.pushReplacementNamed(context, "/");
                return Text("status is SIGNED IN");
                break;
            }
          },
        ),
      ),
    );
  }
}
