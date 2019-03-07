import 'package:broke/interim2.dart';
import 'package:broke/models/sign_in_model.dart';
import 'package:broke/widgets/email_login.dart';
import 'package:broke/widgets/login.dart';
import 'package:broke/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

// - StateWidget incl. state data
//    - RecipesApp
//        - All other widgets which are able to access the data
void main() => runApp(MyApp());
//    runApp(
//      FirebaseLogin(
//        child: MaterialApp(
//          debugShowCheckedModeBanner: false,
//          title: 'Recipes',
//          theme: buildTheme(),
//          home: FirebaseLogin(
//            child: HomeScreen(),
//          ),
//        ),
//      ),
//    );

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
            '/': (context) => Page1(),
            'login': (context) => LoginScreen(),
            'email': (context) => EmailLoginScreen(),
          },
        )
    );
  }
}

// Photo by Brooke Lark on Unsplash


// 1. https://medium.com/@michael.krol/simple-recipes-app-made-in-flutter-introduction-c80964167a19
// 2. https://medium.com/flutter-community/simple-recipes-app-made-in-flutter-detail-view-and-settings-widget-9a7ca9ebec93
// 3. https://medium.com/flutter-community/simple-recipes-app-made-in-flutter-firebase-and-google-sign-in-14d1535e9a59
// 4. https://medium.com/flutter-community/simple-recipes-app-made-in-flutter-firestore-f386722102da

// Item 3 leads to;
// ref: followed: https://firebase.google.com/docs/flutter/setup
// followed: https://flutter.dev/docs/get-started/install/macos "Xcode signing flow"
// This is needed: https://stackoverflow.com/a/54507257/1402287
// for debug signing cert SHA-1: https://developers.google.com/android/guides/client-auth
// keytool -exportcert -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
// and https://stackoverflow.com/questions/18589694/i-have-never-set-any-passwords-to-my-keystore-and-alias-so-how-are-they-created
// had to bump minsdkversion to 21 according to
// https://stackoverflow.com/questions/52250231/flutterfire-firebase-auth-does-not-work-anymore/52250665
// Used console for project: https://console.firebase.google.com/u/0/project/broke-c38d3/overview
// I also came across this: https://www.gotut.net/flutter-firestore-tutorial-part-1/
// which seems not bad

// https://github.com/tattwei46/flutter_login_demo
