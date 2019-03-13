

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';

class Spend {
  final String id;
  final String face;
  final String category;
  final int amount;
  final String note;
  final Timestamp created;

  Spend({
    this.id,
    this.face,
    this.category,
    this.amount,
    this.note,
    this.created,
  });

  @override
  String toString() {
    return "Spend{id:$id,face:$face,category:$category,amount:$amount,created:$created,note:$note}";
  }

  /// The parameter is parsed from the json file, as exported from kidspend.
  factory Spend.fromKidspend(Map<String, dynamic> map) {
    return Spend(
      face: map['mGirl'],
      category: map['mSpendType'],
      amount: map['mAmount'],
      created: Timestamp.fromDate(fromKidspendDate(map['mCreated'])),
    );
  }

  /// Create new instance from firebase map.
  Spend.fromMap(Map<String, dynamic> map, String id) : this(
    id: id,
    face: map['face'],
    category: map['category'],
    amount: map['amount'],
    note: map['note'],
    created: map['created'],
  );

  /// Makes a map suitable for adding to firestore.
  Map<String, dynamic> getMap() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['face'] = face;
    map['category'] = category;
    map['amount'] = amount;
    map['note'] = note;
    map['created'] = created;
    return map;
  }

  /// Reads the json from the exported kidspend asset and adds each record
  /// to the firebase "spends" collection (which is first emptied).
  static void importFromAssets() async {
    CollectionReference collection = Firestore.instance.collection('spends');
    QuerySnapshot snapshot = await collection.getDocuments();

    Firestore.instance.runTransaction((Transaction tx) {
      List<DocumentSnapshot> documents = snapshot.documents;
      print("deleting ${documents.length} documents from spends collection...");
      for (int i = 0; i < documents.length; i++) {
        String docId = documents[i].documentID;
        DocumentReference document = collection.document(docId);
        print("deleting document: ${document.path}");
        document.delete();
      }
    });

    // Directory appDocDir = await getApplicationDocumentsDirectory();
    //String appDocPath = appDocDir.path;
    String contents = await rootBundle.loadString('assets/kidspend-export.json');

    Map<String, dynamic> parsedJson = json.decode(contents);
    List<dynamic> list = parsedJson['spends'];
    for (int i = 0; i < list.length; i++) {
      Map<String, dynamic> map = list[i];
      Spend spend = Spend.fromKidspend(map);
      DocumentReference document = await collection.add(spend.getMap());
      print("added document: ${document.path}");
    }
    print("added ${list.length} documents to spends collection");
  }

  /// Returns a DateTime made from the kidspend-exported date string.
  /// Expecting a format like: "12 MAR 2019"
  static DateTime fromKidspendDate(String kidspendDate) {
    DateTime dateTime;
    List<String> fields = kidspendDate.split(" ");
//    print("parsed $kidspendDate => $fields");
    if (fields?.length == 3) {
      int day = int.parse(fields[0]);
      int month = 0;
      switch (fields[1].toLowerCase()) {
        case "jan": month = 1; break;
        case "feb": month = 2; break;
        case "mar": month = 3; break;
        case "apr": month = 4; break;
        case "may": month = 5; break;
        case "jun": month = 6; break;
        case "jul": month = 7; break;
        case "aug": month = 8; break;
        case "sep": month = 9; break;
        case "oct": month = 10; break;
        case "nov": month = 11; break;
        case "dec": month = 12; break;
        default: throw Exception("bad month in kidspendDate: '" + kidspendDate + "'");
      }
      int year = int.parse(fields[2]);
      dateTime = DateTime(year, month, day);
      print("parsed $kidspendDate => $dateTime");
    }
    return dateTime;
  }

}
