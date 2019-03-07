

import 'package:broke/models/sign_in_model.dart';
import 'package:broke/widgets/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scoped_model/scoped_model.dart';

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('Page1,build ${SignInModel.of(context).authStatus}');
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

