

import 'package:broke/models/sign_in_model.dart';
import 'package:broke/widgets/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scoped_model/scoped_model.dart';

class Page1 extends StatefulWidget {
  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  bool isBusy;

  @override
  void initState() {
    super.initState();
    isBusy = false;
  }

  @override
  Widget build(BuildContext context) {
    print('Page1,build ${SignInModel.of(context).authStatus}');
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            title: Text("page 1 Route"),
          ),
          body: Center(
            child: RaisedButton(
              onPressed: () async {
                setState(() { isBusy = true; });
                await SignInModel.of(context).signOut();
                setState(() { isBusy = false; });
                Navigator.of(context).pushNamedAndRemoveUntil("login", (Route<dynamic> route) => false);
              },
              child: Text('Sign out'),
            ),
          ),
        ),
        isBusy ?
        Stack(
          children: [
            Opacity(
              opacity: 0.7,
              child: const ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(
              child: Container(
                width: 100.0,
                height: 100.0,
                child: CircularProgressIndicator(
                  strokeWidth: 10,
                ),
              ),
            ),
          ],
        ) : Container(),
      ],
    );
  }
}
