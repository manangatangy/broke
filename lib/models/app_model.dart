import 'dart:async';
import 'package:broke/services/authentication.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// App wide data held at the root.
class AppModel {
  bool isLoading;
  FirebaseUser user;

  AppModel({
    this.isLoading = false,
    this.user,
  });
}

class AppModelProvider extends StatefulWidget {
  final AppModel appModel;
  final Widget child;

  AppModelProvider({
    @required this.child,
    this.appModel,
  });

  // Returns data of the nearest widget _ProviderWidget in the widget tree.
  static _AppModelProviderState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_ProviderWidget) as _ProviderWidget).appModelProvider;
  }

  @override
  _AppModelProviderState createState() => new _AppModelProviderState();
}

class _AppModelProviderState extends State<AppModelProvider> {
  AppModel appModel;
  GoogleSignInAccount googleAccount;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  @override
  void initState() {
    super.initState();
    if (widget.appModel != null) {
      appModel = widget.appModel;
    } else {
      appModel = new AppModel(isLoading: true);
      initUser();
    }
  }

  /// Checks if user is already signed in to google, or can be signed
  /// in silently, and then signs into firebase.  Otherwise just turns
  /// off the loading spinner.
  Future<Null> initUser() async {
    googleAccount = await getGoogleSignInAccount(googleSignIn);
    // If user is already signed in to google, then
    if (googleAccount != null) {
      await signInWithGoogle();
    } else {
      setState(() {
        appModel.isLoading = false;
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
        appModel.isLoading = false;
        appModel.user = firebaseUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new _ProviderWidget(
      appModelProvider: this,
      child: widget.child,
    );
  }
}

class _ProviderWidget extends InheritedWidget {
  final _AppModelProviderState appModelProvider;

  _ProviderWidget({
    Key key,
    @required Widget child,
    @required this.appModelProvider,
  }) : super(key: key, child: child);

  // Rebuild the widgets that inherit from this widget
  // on every rebuild of _ProviderWidget:
  @override
  bool updateShouldNotify(_ProviderWidget old) => true;
}
