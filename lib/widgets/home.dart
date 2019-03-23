import 'dart:convert';

import 'package:broke/models/sign_in.dart';
import 'package:broke/models/spend.dart';
import 'package:broke/widgets/fancy_fab.dart';
import 'package:broke/widgets/images.dart';
import 'package:broke/widgets/spend_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool isBusy;

  @override
  void initState() {
    super.initState();
    isBusy = false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        buildContent(context),
//        _buildTabView(),
        _busyIndicator(),
      ],
    );
  }

  Map<String, List<Spend>> categoriesMap(List<DocumentSnapshot> documents) {
    var cats = Map<String, List<Spend>>();
    documents.forEach((document) {
      var spend = Spend.fromMap(document.data, document.documentID);
      if (!cats.containsKey(spend.category)) {
        cats[spend.category] = List<Spend>();
      }
      cats[spend.category].add(spend);
    });
    return cats;
  }

  Widget buildContent(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('spends').where("face", isEqualTo: "RACHEL").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          if (!snapshot.hasData) return Text('Loading...');

          Map<String, List<Spend>> catMap = categoriesMap(snapshot.data.documents);

          return DefaultTabController(
            length: catMap.keys.length,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Navigation example'),
              ),
              floatingActionButton: FancyFab(

              ),
              body: Padding(
                padding: const EdgeInsets.all(5.0),
                child: TabBarView(
                  children: catMap.keys.map((String cat) =>
                      Column(
                        children: <Widget>[
                          Expanded(
                            child: ListView(
                              children: catMap[cat].map((Spend spend) =>
                                  SpendCard(
                                    spend: spend,
                                  ),
                              ).toList(),
                            ),
                          ),
                        ],
                      ),
                  ).toList(),
                ),
              ),
              bottomNavigationBar: Material(
                color: Theme.of(context).primaryColor,
                child: TabBar(
                  isScrollable: true,
                  tabs: catMap.keys.map((String cat) =>
                      Tab(
                        text: cat.toUpperCase(),
                        icon: getIconForCategory(cat),
                      ),
                  ).toList(),
                ),
              ),
            ),
          );
        }
    );
  }


  DefaultTabController _buildTabView() {
    const double _iconSize = 40.0;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: PreferredSize(
          // We set Size equal to passed height (50.0) and infinite width:
          preferredSize: Size.fromHeight(60.0),
          child: AppBar(
            elevation: 2.0,
            bottom: TabBar(
              labelColor: Theme.of(context).indicatorColor,
              tabs: getIcons(_iconSize),
//                Tab(icon: Icon(Icons.local_drink, size: _iconSize)),
//                Tab(icon: Icon(Icons.favorite, size: _iconSize)),
//                Tab(icon: Icon(Icons.settings, size: _iconSize)),

            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(5.0),
          child: _buildTabsContent(),
        ),
      ),
    );
  }

  TabBarView _buildTabsContent() {
    Padding _buildSpends({String face, String category}) {
      CollectionReference collection = Firestore.instance.collection('spends');
      Query query = collection.where("face", isEqualTo: face);
      if (category != null) {
        query = query.where("category", isEqualTo: category);
      }
      Stream<QuerySnapshot> stream = query.snapshots();

      return Padding(
        // Padding before and after the list view:
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                stream: stream,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return _busyIndicator();
                  return new ListView(
                    children: snapshot.data.documents.map<SpendCard>((document) {
                      return new SpendCard(
                        spend: Spend.fromMap(document.data, document.documentID),
//                        inFavorites: appState.favorites.contains(document.documentID),
//                        onFavoriteButtonPressed: _handleFavoritesListChanged,
                      );
                    }).toList(),
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
          Center(
            child: Icon(Icons.settings),
          ),
          RaisedButton(
            onPressed: () async {
              setState(() {
                isBusy = true;
              });
              await SignInModel.of(context).signOut();
              setState(() {
                isBusy = false;
              });
              Navigator.of(context).pushNamedAndRemoveUntil("login", (Route<dynamic> route) => false);
            },
            child: Text('Sign out'),
          ),
          RaisedButton(
            child: Text('Delete spends and import from assets'),
            onPressed: () => Spend.importFromAssets(),
          ),
        ],
      );
    }

    return TabBarView(
      children: [
        _buildSpends(face: "RACHEL", category: "Cosmetics"),
        _buildSpends(face: "CLAIRE"),
        _buildSpends(face: "NINA"),
        _buildSettings(),
      ],
    );
  }

//  // Inactive widgets are going to call this method to
//  // signalize the parent widget HomeScreen to refresh the list view:
//  void _handleFavoritesListChanged(String recipeID) {
//    setState(() {
//      if (userFavorites.contains(recipeID)) {
//        userFavorites.remove(recipeID);
//      } else {
//        userFavorites.add(recipeID);
//      }
//    });
//  }

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
