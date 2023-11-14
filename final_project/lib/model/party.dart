import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/model/firestore_model_utils.dart';

const kPartiesCollectionPath = "parties";
const kPartiesName = "partyName";
const kPartiesIDs = "characterList";
const kPartiesLastTouched = "lastTouched";
const kPartiesAuthorUid = "authorUid";

class Party {
  String? documentId;
  //String authorUid;
  String name;
  String characters;
  Timestamp lastTouched;
  //bool selected;

  Party({
    this.documentId,
    //required this.authorUid,
    required this.lastTouched,
    required this.characters,
    required this.name,
    //this.selected = false,
  }) {
    print("PARTY CONSTRUCTOR");
    //print(authorUid);
  }

  Party.from(DocumentSnapshot doc)
      : this(
            documentId: doc.id,
            //authorUid:
            //FirestoreModelUtils.getStringField(doc, kPartiesAuthorUid),
            name: FirestoreModelUtils.getStringField(doc, kPartiesName),
            characters: FirestoreModelUtils.getStringField(doc, kPartiesIDs),
            lastTouched: FirestoreModelUtils.getTimestampField(
                doc, kPartiesLastTouched));

  // Preparing this for MUCH later.
  Map<String, Object?> toMap() => {
        kPartiesName: name,
        kPartiesIDs: characters,
        //kPartiesAuthorUid: authorUid,
        kPartiesLastTouched: lastTouched,
      };
}
