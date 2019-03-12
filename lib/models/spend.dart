

import 'package:cloud_firestore/cloud_firestore.dart';

class Spend {
  final String id;
  final String face;
  final String category;
  final int amount;
  final String note;
  final Timestamp createDate;

  Spend({
    this.id,
    this.face,
    this.category,
    this.amount,
    this.note,
    this.createDate,
  });

  // Expecting a format like: "12 MAR 2019"
  static DateTime from(String kidspendDate) {
    DateTime dateTime;
    List<String> fields = kidspendDate.split(" ");
    if (fields?.length != 3) {
      int year = int.tryParse(fields[0]);
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
        case "dev": month = 12; break;
        default: throw Exception("bad month in kidspendDate: '" + kidspendDate + "'");
      }
      int day = int.tryParse(fields[2]);
      dateTime = DateTime(year, month, day);
    }
    return dateTime;
  }

  /*

DateTime date

I/flutter (15657): spend {mAmount: 15, mCreated: 12 MAR 2019, mGirl: CLAIRE, mSpendType: Misc}
I/flutter (15657): type _InternalLinkedHashMap<String, dynamic>
I/flutter (15657): key mAmount
I/flutter (15657): value 15
I/flutter (15657): type int
I/flutter (15657): key mCreated
I/flutter (15657): value 12 MAR 2019
I/flutter (15657): type String
I/flutter (15657): key mGirl
I/flutter (15657): value CLAIRE
I/flutter (15657): type String
I/flutter (15657): key mSpendType
I/flutter (15657): value Misc
I/flutter (15657): type String

                 */

//  factory Spend.from(Map<String, dynamic> spend) {}
}

/*
/Firestore(15657): To hide this warning and ensure your app does not break, you need to add the following code to your app before calling any other Cloud Firestore methods:
W/Firestore(15657):
W/Firestore(15657): FirebaseFirestore firestore = FirebaseFirestore.getInstance();
W/Firestore(15657): FirebaseFirestoreSettings settings = new FirebaseFirestoreSettings.Builder()
W/Firestore(15657):     .setTimestampsInSnapshotsEnabled(true)
W/Firestore(15657):     .build();
W/Firestore(15657): firestore.setFirestoreSettings(settings);
W/Firestore(15657):
W/Firestore(15657): With this change, timestamps stored in Cloud Firestore will be read back as com.google.firebase.Timestamp objects instead of as system java.util.Date objects. So you will also need to update code expecting a java.util.Date to instead expect a Timestamp. For example:
W/Firestore(15657):
W/Firestore(15657): // Old:
W/Firestore(15657): java.util.Date date = snapshot.getDate("created_at");
W/Firestore(15657): // New:
W/Firestore(15657): Timestamp timestamp = snapshot.getTimestamp("created_at");
W/Firestore(15657): java.util.Date date = timestamp.toDate();
W/Firestore(15657):
W/Firestore(15657): Please audit all existing usages of java.util.Date when you enable the new behavior. In a future release, the behavior will be changed to the new behavior, so if you do not follow these steps, YOUR APP MAY BREAK.

 com.google.firebase.Timestamp

 */