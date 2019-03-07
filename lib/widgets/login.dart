import 'package:broke/models/sign_in_model.dart';
import 'package:broke/widgets/email_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

/// This is the entry login screen with buttons for login by email and google.
class LoginScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    BoxDecoration _buildBackground() {
      return BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/brooke-lark-385507-unsplash.jpg"),
          fit: BoxFit.cover,
        ),
      );
    }

    Text _buildText() {
      return Text(
        'Recipes',
        style: Theme.of(context).textTheme.headline,
        textAlign: TextAlign.center,
      );
    }

    return Scaffold(
      body: Container(
        decoration: _buildBackground(),
        child: ScopedModelDescendant<SignInModel>(
          builder: (context, child, model) {
            print("PageLogin.build: ${model.authStatus}");
            switch (model.authStatus) {
              case AuthStatus.INIT:
                model.init();
                // TODO translucent spinner over the background
                return Center(
                  child: CircularProgressIndicator(),
                );
                break;
              case AuthStatus.NOT_SIGNED_IN:
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildText(),
                      SizedBox(height: 50.0),
                      SignInButton(
                        text: "Sign in with Email",
                        asset: "assets/mail_icon.png",
                        onPressed: () async {
                          // TODO test if a bool can be popped and what value it is when back clicked
                          FirebaseUser user = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EmailLoginScreen(signInModel: model,)),
                          );
//                          print("PageLogin emailLoginScreen returned: $user and status: ${model.authStatus}");
//
//                          // From: https://medium.com/flutter-community/flutter-push-pop-push-1bb718b13c31
//                          Navigator.of(context).pushNamedAndRemoveUntil("/", (Route<dynamic> route) => false);
//                          if (model.authStatus == AuthStatus.SIGNED_IN) {
//                            // Email page has signed in so change route to the home page.
//                            print("PageLogin has signed-in, popping /");
//                            // TODO test if pop causes a exc like the psuhReplacement does
//                            Navigator.pop(context);
//                          }
                        },
                      ),
                      SizedBox(height: 30.0),
                      SignInButton(
                        text: "Sign in with Google",
                        asset: "assets/g_logo.png",
                        // This function may cause state change -> signed-in, in which
                        // case this widget will be rebuilt with the new state, causing
                        // the route to change.
                        onPressed: () => model.signInWithGoogle(),
                      ),
                    ],
                  ),
                );
                break;
              case AuthStatus.SIGNED_IN:
                // Change route to the home page.
                Navigator.pushReplacementNamed(context, "/");
                return Container();
                break;
            }
          },
        ),
      ),
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
