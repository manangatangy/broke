import 'package:broke/services/repo.dart';
import 'package:broke/services/bloc.dart';
import 'package:broke/models/spend.dart';
import 'package:broke/widgets/fancy_fab.dart';
import 'package:broke/widgets/spend_card.dart';
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
        busyIndicator(),
      ],
    );
  }

  Widget buildContent(BuildContext context) {
    final bloc = Bloc.of(context);
    return StreamBuilder<String>(
      stream: bloc.faceDataStream,
      initialData: "RACHEL",
      builder: (context, snapshot) => buildContent2(context, snapshot.data),
    );
  }

  Widget buildContent2(BuildContext context, String face) {
    return StreamBuilder<CatSpendGroups>(
        stream: categorisedSpendGroupsStream(face),
        builder: (BuildContext context, AsyncSnapshot<CatSpendGroups> categorisedSpendSnapshot) {
          if (categorisedSpendSnapshot.hasError) return Text('Error: ${categorisedSpendSnapshot.error}');
          if (!categorisedSpendSnapshot.hasData) return Text('Loading...');

          Map<String, SpendGroup> catSpends = categorisedSpendSnapshot.data.catGroups;

          return DefaultTabController(
            length: catSpends.keys.length,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Spends: ' + face),
              ),
              floatingActionButton: FancyFab(

              ),
              body: Padding(
                padding: const EdgeInsets.all(5.0),
                child: TabBarView(
                  children: catSpends.keys.map((String cat) =>
                      Column(
                        children: <Widget>[
                          Expanded(
                            child: ListView(
                              children: catSpends[cat].spends.map((Spend spend) =>
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
                  tabs: catSpends.keys.map((String cat) =>
                      Tab(
                          text: cat.toUpperCase(),
                          icon: ImageIcon(
                            catSpends[cat].assetImage,
                            size: 32.0,
                          )
                      ),
                  ).toList(),
                ),
              ),
            ),
          );
        }
    );
  }

  Widget busyIndicator() {
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
