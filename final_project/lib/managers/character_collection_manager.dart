import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/managers/auth_manager.dart';
import 'package:final_project/model/character.dart';
import 'package:flutter/material.dart';

class CharacterCollectionManager {
  // Not actually need after the Firebase UI Firestore refactor
  List<Character> latestCharacters = [];

  final CollectionReference _ref;

  static final instance = CharacterCollectionManager._privateConstructor();
  CharacterCollectionManager._privateConstructor()
      : _ref = FirebaseFirestore.instance.collection(kCharactersCollectionPath);

  // Not actually need after the Firebase UI Firestore refactor
  StreamSubscription startListening(Function observer) {
    return _ref
        .orderBy(kCharactersLastTouched, descending: true)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      latestCharacters =
          querySnapshot.docs.map((doc) => Character.from(doc)).toList();
      observer();
    }, onError: (error) {
      debugPrint("Error listening $error");
    });
  }

  // Not actually need after the Firebase UI Firestore refactor
  void stopListening(StreamSubscription? subscription) {
    subscription?.cancel();
  }

  Query<Character> get allCharactersQuery =>
      _ref.orderBy(kCharactersLastTouched, descending: true).withConverter(
            fromFirestore: (snapshot, _) => Character.from(snapshot),
            toFirestore: (mq, _) => mq.toMap(),
          );

  Query<Character> get onlyMyCharactersQuery => allCharactersQuery
      .where(kCharactersAuthorUid, isEqualTo: AuthManager.instance.uid);

  void add({
    required String name,
    required String characterClass,
    required int level,
  }) {
    _ref.add({
      kCharactersAuthorUid: AuthManager.instance.uid,
      kCharactersName: name,
      kCharactersClass: characterClass,
      kCharactersLevel: level,
      kCharactersLastTouched: Timestamp.now(),
    }).then((docId) {
      print("Finished adding a document that now has id $docId");
    }).catchError((error) {
      print("There was an error adding the document $error");
    });
  }
}
