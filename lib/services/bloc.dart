import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:rxdart/subjects.dart';

class Bloc extends Model {
  static Bloc of(BuildContext context) => ScopedModel.of<Bloc>(context);


  final BehaviorSubject<String>_statusDataSubject = BehaviorSubject<String>();

  Stream<String> get statusDataStream => _statusDataSubject.stream;

  void doIt() {
    _statusDataSubject.add("event");
  }

  void dispose() {
    _statusDataSubject.close();
  }

}
