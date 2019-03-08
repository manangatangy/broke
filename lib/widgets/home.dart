
import 'package:broke/models/recipe.dart';
import 'package:broke/models/sign_in.dart';
import 'package:broke/models/store.dart';
import 'package:broke/widgets/recipe_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool isBusy;
  List<Recipe> recipes = getRecipes();
  List<String> userFavorites = getFavoritesIDs();

  @override
  void initState() {
    super.initState();
    isBusy = false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _buildTabView(
          body: _buildTabsContent(),
        ),
        _busyIndicator(),
      ],
    );
  }

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
    Widget _buildSettings() {
      return Column(
        children: <Widget>[
          Center(child: Icon(Icons.settings),),
          RaisedButton(
            onPressed: () async {
              setState(() { isBusy = true; });
              await SignInModel.of(context).signOut();
              setState(() { isBusy = false; });
              Navigator.of(context).pushNamedAndRemoveUntil("login", (Route<dynamic> route) => false);
            },
            child: Text('Sign out'),
          ),
        ],
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
        _buildSettings(),
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

  Widget _busyIndicator() {
    if (!isBusy) {
      return Container();
    }
    return Stack(
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
    );
  }
}
