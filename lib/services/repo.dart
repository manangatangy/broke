import 'package:broke/models/spend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class CatSpendGroups {
  final String face;
  final Map<String, SpendGroup> catGroups;    // keyed by category.

  CatSpendGroups({
    this.face,
    this.catGroups,
  });
}

class SpendGroup {
  final List<Spend> spends;
  final AssetImage assetImage;
  
  SpendGroup({
    this.spends,
    this.assetImage,
  });
}

/// Return a stream of [CatSpendGroups] from the "spends" collection for the specified [face].
/// This class has an [ImageIcon] and a map (keyed by the category) of [Spend]s for that face and category.
Stream<CatSpendGroups> categorisedSpendSnapshots(String face) {
  Stream<QuerySnapshot> snapshots = Firestore.instance.collection('spends').where("face", isEqualTo: face).snapshots();
  
  return snapshots.map<CatSpendGroups>((QuerySnapshot snapshot) {
    
    List<DocumentSnapshot> documents = snapshot.documents;
    var catGroups =  Map<String, SpendGroup>();
    
    documents.forEach((document) {
      var spend = Spend.fromMap(document.data, document.documentID);
      if (!catGroups.containsKey(spend.category)) {
        catGroups[spend.category] = SpendGroup(
          spends: List<Spend>(),
          assetImage: AssetImage(iconImagePath(IconMap[spend.category]))
        );
      }
      catGroups[spend.category].spends.add(spend);
    });
    return CatSpendGroups(
      face: face,
      catGroups: catGroups,
    );
  });
}

/// keyed by the icon file name; not all icon files have a mapped category
const Map<String, String> CatMap = const<String, String>{
  'bicycle': 'Bike',
  'bunny': 'Misc',
  'car': 'Car',
  'cat': 'Offset',
  'coins': 'Cash',
  'credit': 'Board',
  'dance': 'Party',
  'diploma': 'Course',
  'doughnut': null,
  'first-aid-kit': null,
  'football': null,
  'groceries': null,
  'hand-money': 'Debt',
  'hanger': 'Clothes',
  'laptop': 'Computer',
  'makeup': 'TafeCourse',
  'mascara': 'Cosmetics',
  'mobile-app': null,
  'mobile-phone': 'Phone',
  'money-bag': 'Money',
  'mortarboard': 'Hecs',
  'photo-camera': 'Camera',
  'pint': 'Alcohol',
  'shopping-bag': 'Gift',
  'stethoscope': 'Medical',
  'sunset': 'RussiaTrip',
  'tiger': 'Tigrettes',
  'video-camera': null,
  'world': 'Travel',
};
/// iconMap is a reverse map of CatMap. Ie. iconMap:category->iconFile, where CatMap:iconFile->category
const Map<String, String> IconMap = const<String, String>{
  'Bike': 'bicycle',
  'Misc': 'bunny',
  'Car': 'car',
  'Offset': 'cat',
  'Cash': 'coins',
  'Board': 'credit',
  'Party': 'dance',
  'Course': 'diploma',
  'null0': 'doughnut',
  'null1': 'first-aid-kit',
  'null2': 'football',
  'null3': 'groceries',
  'Debt': 'hand-money',
  'Clothes': 'hanger',
  'Computer': 'laptop',
  'TafeCourse': 'makeup',
  'Cosmetics': 'mascara',
  'null4': 'mobile-app',
  'Phone': 'mobile-phone',
  'Money': 'money-bag',
  'Hecs': 'mortarboard',
  'Camera': 'photo-camera',
  'Alcohol': 'pint',
  'Gift': 'shopping-bag',
  'Medical': 'stethoscope',
  'RussiaTrip': 'sunset',
  'Tigrettes': 'tiger',
  'null5': 'video-camera',
  'Travel': 'world',
};

String iconImagePath(String iconFile) {
  return 'assets/icons/' + iconFile + '.png';
}

ImageIcon getIconForCategory(String category) {
  return ImageIcon(
    AssetImage('assets/icons/' + IconMap[category] + '.png'),
    size: 32.0,
  );
}

const List<String> IconList = const<String>[
  'bicycle',
  'bunny',
  'car',
  'cat',
  'coins',
  'credit',
  'dance',
  'diploma',
  'doughnut',
  'first-aid-kit',
  'football',
  'groceries',
  'hand-money',
  'hanger',
  'laptop',
  'makeup',
  'mascara',
  'mobile-app',
  'mobile-phone',
  'money-bag',
  'mortarboard',
  'photo-camera',
  'pint',
  'shopping-bag',
  'stethoscope',
  'sunset',
  'tiger',
  'video-camera',
  'world',
];
