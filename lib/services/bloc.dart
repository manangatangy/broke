import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:rxdart/subjects.dart';

class Bloc extends Model {
  static Bloc of(BuildContext context) => ScopedModel.of<Bloc>(context);

  final BehaviorSubject<String>_faceDataSubject = BehaviorSubject<String>();

  Stream<String> get faceDataStream => _faceDataSubject.stream;

  void setFace(String face) {
    _faceDataSubject.add(face);
  }

  void dispose() {
    _faceDataSubject.close();
  }

}
