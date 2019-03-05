import 'dart:async';
import 'package:broke/services/authentication.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// App wide data held at the root.
//class AppModel {
//  bool isLoading;
//  FirebaseUser user;
//
//  AppModel({
//    this.isLoading = false,
//    this.user,
//  });
//}

/// Checks for different login methods and builds a login screen if necessary.
/// Also provides a inherited widget access to some global firebase stuff via
/// the State.
class FirebaseLoginxx extends StatefulWidget {
//  final AppModel appModel;
  final Widget child;

  FirebaseLoginxx({
    @required this.child,
//    this.appModel,
  });

  static FirebaseLoginxxState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(RootDataxx) as RootDataxx).firebaseLoginState;
  }

  @override
  FirebaseLoginxxState createState() => new FirebaseLoginxxState();
}

class FirebaseLoginxxState extends State<FirebaseLoginxx> {
//  AppModel appModel;
  bool isLoading;
  FirebaseUser user;
  GoogleSignInAccount googleAccount;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  @override
  void initState() {
    super.initState();
//    appModel = new AppModel(isLoading: true);
    initUser();
  }

  /// Checks if user is already signed in to google, or can be signed
  /// in silently, and then signs into firebase.  Otherwise just turns
  /// off the loading spinner.
  Future<Null> initUser() async {
    isLoading = true;
    googleAccount = await getGoogleSignInAccount(googleSignIn);
    // If user is already signed in to google, then
    if (googleAccount != null) {
      await signInWithGoogle();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Starts the interactive sign-in to google (unless already signed in)
  /// and then signs in to firebase, using the google account.
  Future<Null> signInWithGoogle() async {
    if (googleAccount == null) {
      // Start the sign-in process:
      googleAccount = await googleSignIn.signIn();
    }
    if (googleAccount != null) {
      FirebaseUser firebaseUser = await googleSignIntoFirebase(googleAccount);
      setState(() {
        isLoading = false;
        user = firebaseUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new RootDataxx(
      firebaseLoginState: this,
      child: widget.child,
    );
  }
}

class RootDataxx extends InheritedWidget {
  final FirebaseLoginxxState firebaseLoginState;

  RootDataxx({
    Key key,
    @required Widget child,
    @required this.firebaseLoginState,
  }) : super(key: key, child: child);

  // Rebuild the widgets that inherit from this widget
  // on every rebuild of _ProviderWidget:
  @override
  bool updateShouldNotify(RootDataxx old) => true;
}
