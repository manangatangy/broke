
import 'package:broke/widgets/firebase_storage_example.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:scoped_model/scoped_model.dart';

class FirebaseModel extends Model {

  FirebaseStorage firebaseStorage;
  Firestore firestore;

  static FirebaseModel of(BuildContext context) => ScopedModel.of<FirebaseModel>(context);

  Future<void> configure() async {
    print("FirebaseModel configure");
    // Ref: https://stackoverflow.com/questions/51112963/how-to-configure-firebase-firestore-settings-with-flutter
//    firebaseStorage = await configureFirebaseStorage();
//    firestore = Firestore(app: firebaseStorage.app);
//    await firestore.settings(timestampsInSnapshotsEnabled: true);
    firebaseStorage = FirebaseStorage();
  }

}
