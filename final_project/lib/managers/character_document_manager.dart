import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/model/character.dart';
import 'package:flutter/material.dart';

class CharacterDocumentManager {
  Character? latestCharacter;
  final CollectionReference _ref;

  static final instance = CharacterDocumentManager._privateConstructor();
  CharacterDocumentManager._privateConstructor()
      : _ref = FirebaseFirestore.instance.collection(kCharactersCollectionPath);

  StreamSubscription startListening({
    required String documentId,
    required Function observer,
  }) {
    return _ref.doc(documentId).snapshots().listen(
        (DocumentSnapshot documentSnapshot) {
      latestCharacter = Character.from(documentSnapshot);
      observer();
    }, onError: (error) {
      print("Error getting the document $error");
    });
  }

  void stopListening(StreamSubscription? subscription) {
    subscription?.cancel();
  }

  void update({
    required String name,
    required String characterClass,
    required int level,
  }) {
    _ref.doc(latestCharacter!.documentId!).update({
      kCharactersName: name,
      kCharactersClass: characterClass,
      kCharactersLevel: level,
      kCharactersLastTouched: Timestamp.now(),
    }).then((_) {
      print("Finished updating the document");
    }).catchError((error) {
      print("There was an error adding the document $error");
    });
  }

  void delete() {
    _ref.doc(latestCharacter!.documentId!).delete();
  }
}
