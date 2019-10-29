import 'package:broke/services/sign_in.dart';
import 'package:broke/models/spend.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
        RaisedButton(
          child: Text('Analyse import from assets'),
          onPressed: () => Spend.analyseImportFile(),
        ),
      ],
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
