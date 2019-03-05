import 'package:broke/services/authentication.dart';
import 'package:broke/widgets/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Checks for different login methods and builds a login screen if necessary.
/// Also provides a inherited widget access to some global firebase stuff via
/// the State.
class FirebaseLogin extends StatefulWidget {
  final Auth auth;
  final Widget child;

  FirebaseLogin({
    this.auth,
    this.child,
  });

  @override
  State<StatefulWidget> createState() => new FirebaseLoginState();

  static FirebaseLoginState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(RootData) as RootData).firebaseLoginState;
  }

}

enum AuthStatus {
  UNKNOWN,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class FirebaseLoginState extends State<FirebaseLogin> {

  AuthStatus authStatus = AuthStatus.UNKNOWN;
  FirebaseUser firebaseUser;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();


  String userUid = "";

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
    FirebaseUser user = await widget.auth.getCurrentUser();
    print("initUser:getCurrentUser $user");
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


  void _onLoggedIn() {
    widget.auth.getCurrentUser().then((user){
      setState(() {
        _userId = user.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void _onSignedOut() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return new RootData(
      firebaseLoginState: this,
      child: buildContent(context),
    );
  }

  Widget buildContent(BuildContext context) {
    if (authStatus == AuthStatus.LOGGED_IN) {
      return widget.child;
    } else if (authStatus == AuthStatus.NOT_LOGGED_IN) {
      return LoginSignUpPage(
        auth: widget.auth,
        onSignedIn: _onLoggedIn,
      );
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

class RootData extends InheritedWidget {
  final FirebaseLoginState firebaseLoginState;

  RootData({
    Key key,
    @required Widget child,
    @required this.firebaseLoginState,
  }) : super(key: key, child: child);

  // Rebuild the widgets that inherit from this widget
  // on every rebuild of xx
  @override
  bool updateShouldNotify(RootData old) => true;
}

