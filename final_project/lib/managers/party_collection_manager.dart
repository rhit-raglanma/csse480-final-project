import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/managers/auth_manager.dart';

import 'package:final_project/model/party.dart';

import 'package:flutter/material.dart';

class PartyCollectionManager {
  // Not actually need after the Firebase UI Firestore refactor
  List<Party> latestParties = [];

  final CollectionReference _ref;

  static final instance = PartyCollectionManager._privateConstructor();
  PartyCollectionManager._privateConstructor()
      : _ref = FirebaseFirestore.instance.collection(kPartiesCollectionPath);

  // Not actually need after the Firebase UI Firestore refactor
  StreamSubscription startListening(Function observer) {
    return _ref
        .orderBy(kPartiesLastTouched, descending: true)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      latestParties = querySnapshot.docs.map((doc) => Party.from(doc)).toList();
      observer();
    }, onError: (error) {
      debugPrint("Error listening $error");
    });
  }

  // Not actually need after the Firebase UI Firestore refactor
  void stopListening(StreamSubscription? subscription) {
    subscription?.cancel();
  }

  Query<Party> get allPartiesQuery =>
      _ref.orderBy(kPartiesLastTouched, descending: true).withConverter(
            fromFirestore: (snapshot, _) => Party.from(snapshot),
            toFirestore: (mq, _) => mq.toMap(),
          );

  void testUID() {
    print(AuthManager.instance.uid);
  }

  Query<Party> get onlyMyPartiesQuery => allPartiesQuery
      .where(kPartiesAuthorUid, isEqualTo: AuthManager.instance.uid);

  void add({
    required String name,
    required List<String> characters,
  }) {
    String characterString = "";

    for (String ch in characters) {
      characterString += ch + ",";
    }
    characterString = characterString.substring(0, characterString.length - 1);

    _ref.add({
      kPartiesAuthorUid: AuthManager.instance.uid,
      kPartiesName: name,
      kPartiesIDs: characterString,
      kPartiesLastTouched: Timestamp.now(),
    }).then((docId) {
      print("Finished adding a document that now has id $docId");
    }).catchError((error) {
      print("There was an error adding the document $error");
    });
  }

  void delete(deletedDocumentId) {
    _ref.doc(deletedDocumentId).delete();
  }
}
