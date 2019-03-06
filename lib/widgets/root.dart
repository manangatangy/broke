import 'package:broke/services/authentication.dart';
import 'package:broke/widgets/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scoped_model/scoped_model.dart';

/// The various fields in the FirebaseLoginState are made available via
/// a scopedModel.
class FirebaseRoot extends Model {
  final FirebaseLoginState state;

  FirebaseRoot({
    this.state,
  });

  static FirebaseRoot of(BuildContext context) => ScopedModel.of<FirebaseRoot>(context);
}

/// Checks for different login methods and builds a login screen if necessary.
/// Also provides a scoped model access to some global firebase stuff.
class FirebaseLogin extends StatefulWidget {
  final Widget child;

  FirebaseLogin({
    this.child,
  });

  @override
  State<StatefulWidget> createState() => new FirebaseLoginState();
}

enum AuthStatus {
  UNKNOWN,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class FirebaseLoginState extends State<FirebaseLogin> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  AuthStatus authStatus = AuthStatus.UNKNOWN;
  FirebaseUser firebaseUser;

  @override
  void initState() {
    super.initState();
    initUser();
  }

  /// First checks if there is a current user.  If not, then
  /// checks if user is already signed in to google, or can be signed
  /// in (silently), and then signs into using google.  Otherwise just turns
  /// off the loading spinner.
  Future<Null> initUser() async {
    print("initUser");
    FirebaseUser user = await firebaseAuth.currentUser();
    print("initUser:currentUser $user");
    if (user?.uid != null) {
      setState(() {
        authStatus = AuthStatus.LOGGED_IN;
        firebaseUser = user;
        print("initUser:logged in via email $firebaseUser");
      });
    } else {
      GoogleSignInAccount googleAccount = await getGoogleSignInAccount(googleSignIn);
      print("initUser:getGoogleSignInAccount $googleAccount");
      if (googleAccount != null) {
        // User is already signed in to google, complete the firebase sign in.
        FirebaseUser user = await googleSignIntoFirebase(googleAccount);
        setState(() {
          authStatus = AuthStatus.LOGGED_IN;
          firebaseUser = user;
          print("initUser:logged in via google $firebaseUser");
        });
      } else {
        setState(() {
          authStatus = AuthStatus.NOT_LOGGED_IN;
          print("initUser:not logged in");
        });
      }
    }
  }

  /// Starts the interactive sign-in to google (unless already signed in)
  /// and then signs in to firebase, using the google account.
  Future<Null> signInWithGoogle() async {
    GoogleSignInAccount googleAccount = await googleSignIn.signIn();
    if (googleAccount != null) {
      FirebaseUser user = await googleSignIntoFirebase(googleAccount);
      setState(() {
        authStatus = AuthStatus.LOGGED_IN;
        firebaseUser = user;
        print("signInWithGoogle:signed in via google $firebaseUser");
      });
    }
  }

  /// This should be called by a child in order to change state to logged in/out.
  void onSignedInOrOut() {
    firebaseAuth.currentUser().then((user) {
      print("onSignedInOrOut:currentUser $user");
      setState(() {
        authStatus = (user?.uid != null) ? AuthStatus.LOGGED_IN : AuthStatus.NOT_LOGGED_IN;
        firebaseUser = user;
        print("onSignedInOrOut: authStatus:$authStatus");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FirebaseRoot>(
      model: FirebaseRoot(state: this),
      child: buildContent(context),
    );
  }

  Widget buildContent(BuildContext context) {
    if (authStatus == AuthStatus.LOGGED_IN) {
      return widget.child;
    } else if (authStatus == AuthStatus.NOT_LOGGED_IN) {
      return LoginScreen();
    }
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
}

//        if (_userId.length > 0 && _userId != null) {
//        } else return _buildWaitingScreen();
