import 'package:broke/models/sign_in.dart';
import 'package:broke/widgets/email_login.dart';
import 'package:broke/widgets/home.dart';
import 'package:broke/widgets/login.dart';
import 'package:broke/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<SignInModel>(
        model: SignInModel(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Recipes',
          theme: buildTheme(),
          initialRoute: "login",
//          initialRoute: "/",    // Temporarily mark this as initialRoute to skip the login protocol.
          routes: {
            '/': (context) => HomeScreen(),
            'login': (context) => LoginScreen(),
            'email': (context) => EmailLoginScreen(),
          },
        )
    );
  }
}

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
// Configuring for ios also required editing the [my_project]/ios/Runner/Info.plist file according to
// https://pub.dartlang.org/packages/google_sign_in
// This https://github.com/flutter/plugins/blob/master/packages/google_sign_in/example/lib/main.dart
// is also a good code example of sign in and extract some id data from the google apis as a http request.
// Note that the GoogleUserCircleAvatar widget takes a GoogleSignInAccount parameter.


// https://github.com/tattwei46/flutter_login_demo
// Splash screen info
// https://flutter.dev/docs/development/ui/assets-and-images#updating-the-launch-screen
// This https://medium.com/@diegoveloper/flutter-splash-screen-9f4e05542548
// might fix the delay before showing the splash screen
