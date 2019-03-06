
import 'package:broke/model/recipe.dart';
import 'package:broke/services/authentication.dart';
import 'package:broke/ui/widgets/recipe_card.dart';
import 'package:broke/utils/store.dart';
import 'package:broke/widgets/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void mainX() =>
    runApp(
      AppModelProviderX(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Recipes',
          theme: buildTheme(),
          initialRoute: "/login",
          routes: {
            // If you're using navigation routes, Flutter needs a base route.
            // We're going to change this route once we're ready with
            // implementation of HomeScreen.
            '/': (context) => HomeScreen(),
            '/login': (context) => LoginScreenX(),
          },
        ),
      ),
    );

//--------------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  AppModel appModel;
  List<Recipe> recipes = getRecipes();
  List<String> userFavorites = getFavoritesIDs();

  DefaultTabController _buildTabView({Widget body}) {
    const double _iconSize = 20.0;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: PreferredSize(
          // We set Size equal to passed height (50.0) and infinite width:
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            elevation: 2.0,
            bottom: TabBar(
              labelColor: Theme.of(context).indicatorColor,
              tabs: [
                Tab(icon: Icon(Icons.restaurant, size: _iconSize)),
                Tab(icon: Icon(Icons.local_drink, size: _iconSize)),
                Tab(icon: Icon(Icons.favorite, size: _iconSize)),
                Tab(icon: Icon(Icons.settings, size: _iconSize)),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(5.0),
          child: body,
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (appModel.isLoading) {
      return _buildTabView(
        body: _buildLoadingIndicator(),
      );
//    } else if (!appModel.isLoading && appModel.user == null) {
//      return new LoginScreenX();
    } else {
      return _buildTabView(
        body: _buildTabsContent(),
      );
    }
  }

  Center _buildLoadingIndicator() {
    return Center(
      child: new CircularProgressIndicator(),
    );
  }

  TabBarView _buildTabsContent() {
    Padding _buildRecipes(List<Recipe> recipesList) {
      return Padding(
        // Padding before and after the list view:
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: recipesList.length,
                itemBuilder: (BuildContext context, int index) {
                  return new RecipeCard(
                    recipe: recipesList[index],
                    inFavorites: userFavorites.contains(recipesList[index].id),
                    onFavoriteButtonPressed: _handleFavoritesListChanged,
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      children: [
        _buildRecipes(
            recipes.where((recipe) => recipe.type == RecipeType.food).toList()),
        _buildRecipes(recipes
            .where((recipe) => recipe.type == RecipeType.drink)
            .toList()),
        _buildRecipes(recipes
            .where((recipe) => userFavorites.contains(recipe.id))
            .toList()),
        Center(child: Icon(Icons.settings)),
      ],
    );
  }

  // Inactive widgets are going to call this method to
  // signalize the parent widget HomeScreen to refresh the list view:
  void _handleFavoritesListChanged(String recipeID) {
    setState(() {
      if (userFavorites.contains(recipeID)) {
        userFavorites.remove(recipeID);
      } else {
        userFavorites.add(recipeID);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build the content depending on the state:
    appModel = AppModelProviderX.of(context).appModel;
    return _buildContent();
  }
}

//--------------------------------------------------------------------
/// App wide data held at the root.
class AppModel {
  bool isLoading;
  FirebaseUser user;

  AppModel({
    this.isLoading = false,
    this.user,
  });
}

class AppModelProviderX extends StatefulWidget {
  final AppModel appModel;
  final Widget child;

  AppModelProviderX({
    @required this.child,
    this.appModel,
  });

  // Returns data of the nearest widget _ProviderWidget in the widget tree.
  static _AppModelProviderXState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_ProviderWidget) as _ProviderWidget).appModelProvider;
  }

  @override
  _AppModelProviderXState createState() => new _AppModelProviderXState();
}

class _AppModelProviderXState extends State<AppModelProviderX> {
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

  Future<Null> signOutOfGoogle() async {
    // Sign out from Firebase and Google
    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();
    // Clear variables
    googleAccount = null;
//    state.user = null;
//    setState(() {
//      state = StateModel(user: null);
//    });
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
  final _AppModelProviderXState appModelProvider;

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


//-----------------------------------

class LoginScreenX extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // New private method which includes the background image:
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
      // We do not use backgroundColor property anymore.
      // New Container widget wraps our Center widget:
      body: Container(
        decoration: _buildBackground(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildText(),
              SizedBox(height: 50.0),
              SignInButton(
                text: "Goto home",
                asset: "assets/mail_icon.png",
                onPressed: () {
                  AppModelProviderX.of(context).appModel.isLoading = true;
                  Navigator.pop(
                    context,
                  );
                },
              ),
              SizedBox(height: 50.0),
              SignInButton(
                text: "Sign in with Email",
                asset: "assets/mail_icon.png",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SecondRoute()),
                  );
                },
//                onPressed: () => AppModelProviderX.of(context).signInWithGoogle(),
              ),
              SizedBox(height: 30.0),
              SignInButton(
                text: "Sign in with Google",
                asset: "assets/g_logo.png",
                onPressed: () => AppModelProviderX.of(context).signInWithGoogle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
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
//            "assets/g_logo.png",
//            "assets/mail_icon.png",
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
