
import 'package:broke/models/spend.dart';
import 'package:broke/widgets/images.dart';
import 'package:broke/widgets/spend_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen2 extends StatelessWidget {

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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('spends').where("face", isEqualTo: "NINA").snapshots(),
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
}
