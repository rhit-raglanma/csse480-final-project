import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/model/firestore_model_utils.dart';

const kCharactersCollectionPath = "characters";
const kCharactersName = "name";
const kCharactersLevel = "level";
const kCharactersClass = "class";
const kCharactersLastTouched = "lastTouched";
const kCharactersAuthorUid = "author";

class Character {
  String? documentId;
  String name;
  String characterClass;
  int level;
  Timestamp lastTouched;
  //bool selected;

  Character({
    this.documentId,
    required this.lastTouched,
    required this.characterClass,
    required this.name,
    required this.level,
    //this.selected = false,
  });

  Character.from(DocumentSnapshot doc)
      : this(
            documentId: doc.id,
            name: FirestoreModelUtils.getStringField(doc, kCharactersName),
            characterClass:
                FirestoreModelUtils.getStringField(doc, kCharactersClass),
            level: FirestoreModelUtils.getIntField(doc, kCharactersLevel),
            lastTouched: FirestoreModelUtils.getTimestampField(
                doc, kCharactersLastTouched));

  // Preparing this for MUCH later.
  Map<String, Object?> toMap() => {
        kCharactersName: name,
        kCharactersClass: characterClass,
        kCharactersLevel: level,
        kCharactersLastTouched: lastTouched,
      };
}
