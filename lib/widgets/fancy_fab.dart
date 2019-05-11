
import 'package:broke/services/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FaceData {
  final String name;
  final double offset;
  FaceData({this.name, this.offset});
}

class FancyFab extends StatefulWidget {
  final Function() onPressed;
  final String tooltip;
  final IconData icon;
  final List<String> faces;

  FancyFab({this.onPressed, this.tooltip, this.icon, this.faces});

  @override
  _FancyFabState createState() => _FancyFabState();
}

class _FancyFabState extends State<FancyFab>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;
  List<FaceData> faceDataList = [];

  @override
  initState() {
    for (var i = widget.faces.length; i > 0; i--) {
      faceDataList.add(FaceData(
        name: widget.faces[i - 1],
        offset: i.toDouble(),   // Last iteration value will be 1.0
      ));
    }
    _animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget add() {
    return Container(
      child: FloatingActionButton(
        heroTag: 'addTag',
        onPressed: () {
          animate();
          Navigator.pushNamed(context, 'spendForm');
        },
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget image() {
    return Container(
      child: FloatingActionButton(
        onPressed: null,
        tooltip: 'Image',
        child: Icon(Icons.image),
      ),
    );
  }

  Widget inbox() {
    return Container(
      child: FloatingActionButton(
        onPressed: null,
        tooltip: 'Inbox',
        child: Icon(Icons.inbox),
      ),
    );
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        heroTag: 'toggleTag',
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: 'Toggle',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }


  Widget faceButton(double offset, String face) {
    return Transform(
      transform: Matrix4.translationValues(
        0.0,
        _translateButton.value * offset,
        0.0,
      ),
      child: Container(
        child: FloatingActionButton(
          heroTag: face,
          onPressed: () {
            Bloc.of(context).setFace(face);
            animate();
          },
          child: Text(face),
//          child: Icon(Icons.inbox),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * (faceDataList.length + 1),
            0.0,
          ),
          child: add(),
        ),
        ...faceDataList.map((faceData) => faceButton(faceData.offset, faceData.name)).toList(),
        toggle(),
      ],
    );
  }
}
