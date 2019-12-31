import 'package:broke/services/bloc.dart';
import 'package:broke/services/sign_in.dart';
import 'package:broke/widgets/email_login.dart';
import 'package:broke/widgets/firebase_storage_example.dart';
import 'package:broke/widgets/home.dart';
import 'package:broke/widgets/login.dart';
import 'package:broke/widgets/settings.dart';
import 'package:broke/widgets/spend_form.dart';
import 'package:broke/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

void main() async {
  // Ref: https://stackoverflow.com/questions/51112963/how-to-configure-firebase-firestore-settings-with-flutter
  // Seems to be resolved by 31/12/2019, using cloud-firestore-0.10.1
  runApp(MyApp());
  // xoox
}

class MyApp extends StatelessWidget {
  // The homeRoute is the post-login/check landing screen.
  final String homeRoute = '/';
//  final String homeRoute = 'settings';
//  final String homeRoute = 'upload';

  @override
  Widget build(BuildContext context) {
    return ScopedModel<Bloc>(
      model: Bloc(),
      child: ScopedModel<SignInModel>(
          model: SignInModel(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Recipes',
            theme: buildTheme(),
            // An initialRoute of login will cause a login/check which then routes to homeRoute
            // This login/check is avoided by setting a different initialRoute.
            initialRoute: 'login',
//            initialRoute: 'spendForm',
            routes: {
              'login': (context) => LoginScreen(homeRoute: homeRoute,),
              'email': (context) => EmailLoginScreen(homeRoute: homeRoute,),
              '/': (context) => HomeScreen(),
              'upload': (context) => UploadPage(),
              'settings': (context) => SettingsScreen(),
              'spendForm': (context) => SpendForm(title: 'Title',),
            },
          )
      ),
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

// Create firestore database (use test mode, locked mode TBD https://firebase.google.com/docs/firestore/security/get-started?authuser=0)
// https://flutter.dev/docs/cookbook/persistence/reading-writing-files
// PENGUINS
// https://cdn.empireonline.com/jpg/80/0/0/1200/675/0/0/0/0/0/0/0/t/films/270946/images/GtodNrQnorVd3Gv6f6i4bdEwkP.jpg
// https://firebase.google.com/docs/firestore/manage-data/delete-data
// https://pub.dartlang.org/documentation/cloud_firestore/latest/cloud_firestore/CollectionReference-class.html
// This looks pretty good
// https://grokonez.com/flutter/flutter-firestore-example-firebase-firestore-crud-operations-with-listview

// This https://github.com/flutter/plugins/blob/master/packages/cloud_firestore/example/lib/main.dart
// has good code showing firestore options and flow.


// https://flutter.dev/docs/cookbook/images/cached-images
// https://pub.dartlang.org/packages/flutter_cache_manager
// https://pub.dartlang.org/packages/cached_network_image#-analysis-tab-
// https://stackoverflow.com/questions/49455079/flutter-save-a-network-image-to-local-directory
// https://pub.dartlang.org/packages/firebase_storage#-readme-tab-
// https://stackoverflow.com/questions/44841729/how-to-upload-image-in-flutter
// https://stackoverflow.com/questions/13955813/how-to-store-and-view-images-on-firebase
// https://flutterawesome.com/flutter-floating-action-button-with-speed-dial/


// <div>Icons made by <a href="https://www.freepik.com/" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>\
// <div>Icons made by <a href="https://www.flaticon.com/authors/prettycons" title="prettycons">prettycons</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/monkik" title="monkik">monkik</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/darius-dan" title="Darius Dan">Darius Dan</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/srip" title="srip">srip</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/chris-veigt" title="Chris Veigt">Chris Veigt</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/good-ware" title="Good Ware">Good Ware</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.freepik.com/" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/kiranshastry" title="Kiranshastry">Kiranshastry</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.freepik.com/" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/elias-bikbulatov" title="Elias Bikbulatov">Elias Bikbulatov</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/elias-bikbulatov" title="Elias Bikbulatov">Elias Bikbulatov</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/good-ware" title="Good Ware">Good Ware</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.freepik.com/" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/gregor-cresnar" title="Gregor Cresnar">Gregor Cresnar</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/ctrlastudio" title="Ctrlastudio">Ctrlastudio</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.freepik.com/" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/darius-dan" title="Darius Dan">Darius Dan</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/darius-dan" title="Darius Dan">Darius Dan</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/zlatko-najdenovski" title="Zlatko Najdenovski">Zlatko Najdenovski</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/nikita-golubev" title="Nikita Golubev">Nikita Golubev</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
// <div>Icons made by <a href="https://www.flaticon.com/authors/monkik" title="monkik">monkik</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
//

// https://medium.com/flutterpub/sample-form-part-1-flutter-35664d57b0e5
// https://flutter.dev/docs/cookbook/forms
// https://codingwithjoe.com/building-forms-with-flutter/
// https://flutter.dev/docs/cookbook/forms/text-field-changes
// https://flutter.dev/docs/cookbook/forms/focus
// 