import 'package:broke/models/sign_in_model.dart';
import 'package:broke/widgets/email_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

/// This is the entry login screen with buttons for login by email and google.
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  SignInModel model;

  @override
  void initState() {
    super.initState();
    model = SignInModel.of(context);
  }

  void _onSignIn(bool isSignedIn) {
    print("LoginScreenState isSignedIn => $isSignedIn");
    if (isSignedIn) {
      // This removes the current route (without rebuilding it).
      // TODO maybe move this code to the model, called automatically
      Navigator.of(context).pushNamedAndRemoveUntil("/", (Route<dynamic> route) => false);
    } else {
      setState(() {}); // Rebuild with new model.authStatus
    }
  }

  @override
  Widget build(BuildContext context) {

    AuthStatus authStatus = model.authStatus;
    print("LoginScreenState.build: $authStatus");

    if (authStatus == AuthStatus.INIT) {
      model.checkForSignIn().then(_onSignIn);
    }

    return Scaffold(
      body: Container(
        decoration: _buildBackground(),
        child: Builder(
          builder: (context) {
            switch (authStatus) {
              case AuthStatus.INIT:
                return Center(
                  child: CircularProgressIndicator(),
                );
                break;
              case AuthStatus.NOT_SIGNED_IN:
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildText(context),
                      SizedBox(height: 50.0),
                      SignInButton(
                        text: "Sign in with Email",
                        asset: "assets/mail_icon.png",
                        onPressed: () => Navigator.pushNamed(context, "email"),
                      ),
                      SizedBox(height: 30.0),
                      SignInButton(
                        text: "Sign in with Google",
                        asset: "assets/g_logo.png",
                        onPressed: () {
                          model.signInWithGoogle(null).then(_onSignIn);
                        },
                        // The above call may cause state change -> signed-in, in which
                        // case this widget will be rebuilt with the new state, causing
                        // the route to change.
                      ),
                    ],
                  ),
                );
                break;
              case AuthStatus.SIGNED_IN:
                return Container();
                break;
            }
          },
        ),
      ),
    );
  }

  BoxDecoration _buildBackground() {
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/brooke-lark-385507-unsplash.jpg"),
        fit: BoxFit.cover,
      ),
    );
  }

  Text _buildText(BuildContext context) {
    return Text(
      'BROKE',
      style: Theme.of(context).textTheme.headline,
      textAlign: TextAlign.center,
    );
  }
}

class SignInButton extends StatelessWidget {
  final String text;
  final String asset;
  final Function onPressed;

  SignInButton({
    this.text,
    this.asset,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 40.0,
      onPressed: this.onPressed,
      color: Colors.white,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset(
            asset,
            height: 48.0,
            width: 48.0,
          ),
          SizedBox(width: 24.0),
          Opacity(
            opacity: 0.54,
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Roboto-Medium',
                fontSize: 22,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
