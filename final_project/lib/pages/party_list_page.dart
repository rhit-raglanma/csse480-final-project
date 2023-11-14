import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/components/character_dialog.dart';
import 'package:final_project/components/character_row.dart';
import 'package:final_project/components/list_page_drawer.dart';
import 'package:final_project/managers/auth_manager.dart';
import 'package:final_project/managers/character_collection_manager.dart';
import 'package:final_project/managers/party_collection_manager.dart';
import 'package:final_project/model/character.dart';
import 'package:final_project/model/party.dart';
import 'package:final_project/pages/character_detail_page.dart';
import 'package:final_project/pages/login_front_page.dart';
import 'package:flutter/material.dart';

import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';

class PartyListPage extends StatefulWidget {
  const PartyListPage({super.key});

  @override
  State<PartyListPage> createState() => _PartyListPageState();
}

class _PartyListPageState extends State<PartyListPage> {
  final nameTextController = TextEditingController();
  final classTextController = TextEditingController();
  final levelTextController = TextEditingController();
  final partyTextController = TextEditingController();

  // Not actually need after the Firebase UI Firestore refactor
  StreamSubscription? characterSubscription;
  StreamSubscription? partySubscription;

  UniqueKey? _loginUniqueKey;
  UniqueKey? _logoutUniqueKey;

  bool _isShowingAllCharacters = true;

  bool _isSelecting = false;

  bool _isShowingParty = false;
  Party? currentParty;
  String currentPartyString = "";
  List<String> currentPartyDocuments = [];

  List<String> selectedDocuments = [];

  FirestoreListView? drawerParties;

  @override
  void dispose() {
    nameTextController.dispose();
    classTextController.dispose();
    levelTextController.dispose();
    partyTextController.dispose();

    // Not actually need after the Firebase UI Firestore refactor
    CharacterCollectionManager.instance.stopListening(characterSubscription);

    AuthManager.instance.removeObserver(_loginUniqueKey);
    AuthManager.instance.removeObserver(_logoutUniqueKey);

    super.dispose();
  }

  @override
  void initState() {
    // Not actually need after the Firebase UI Firestore refactor
    characterSubscription =
        CharacterCollectionManager.instance.startListening(() {
      setState(() {});
    });

    partySubscription = PartyCollectionManager.instance.startListening(() {
      setState(() {});
    });

    _loginUniqueKey = AuthManager.instance.addLoginObserver(() {
      setState(() {
        PartyCollectionManager.instance.testUID();
        if (AuthManager.instance.isSignedIn) {
          drawerParties = FirestoreListView<Party>(
            shrinkWrap: true,
            query: PartyCollectionManager.instance.onlyMyPartiesQuery,
            itemBuilder: (context, snapshot) {
              Party mq = snapshot.data();

              return ListTile(
                title: Text(mq.name),
                leading: const Icon(Icons.people),
                onTap: () {
                  _isShowingParty = true;

                  //currentPartyString = mq.characters;
                  currentPartyDocuments = mq.characters.split(",");
                  currentParty = mq;

                  Navigator.of(context).pop();
                  setState(() {});
                },
              );
            },
          );
        }
      });
    });

    _logoutUniqueKey = AuthManager.instance.addLogoutObserver(() {
      setState(() {
        _isShowingAllCharacters = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];

    if (AuthManager.instance.isSignedIn) {
      if (_isSelecting) {
        actions.add(
          IconButton(
            onPressed: () {
              showAddPartyDialog();
            },
            icon: const Icon(Icons.add),
          ),
        );
      }

      if (_isShowingParty) {
        actions.add(
          IconButton(
            onPressed: () {
              setState(() {
                PartyCollectionManager.instance
                    .delete(currentParty!.documentId);
                _isShowingAllCharacters = true;
                _isShowingParty = false;
              });
            },
            icon: const Icon(Icons.delete),
          ),
        );
      }

      actions.add(
        IconButton(
          onPressed: () {
            setState(() {
              _isSelecting = !_isSelecting;
            });
          },
          icon: const Icon(Icons.checklist),
        ),
      );
    } else {
      actions.add(
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const LoginFrontPage(),
              ),
            );
          },
          icon: const Icon(Icons.login),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Characters"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: actions,
      ),
      body: FirestoreListView<Character>(
        query: _isShowingAllCharacters
            ? CharacterCollectionManager.instance.allCharactersQuery
            : CharacterCollectionManager.instance.onlyMyCharactersQuery,
        itemBuilder: (context, snapshot) {
          Character mq = snapshot.data();

          if (_isShowingParty &&
              !currentPartyDocuments.contains(mq.documentId)) {
            return const SizedBox(
              height: 0,
            );
          }

          return CharacterRow(
            selectedIds: selectedDocuments,
            character: mq,
            selectState: _isSelecting,
            onTapCallback: () {
              if (_isSelecting) {
                setState(() {
                  if (selectedDocuments.contains(mq.documentId!)) {
                    selectedDocuments.remove(mq.documentId!);
                  } else {
                    selectedDocuments.add(mq.documentId!);
                  }
                });
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return CharacterDetailPage(mq.documentId!);
                  }),
                );
              }
            },
          );
        },
      ),
      drawer: AuthManager.instance.isSignedIn
          ? ListPageDrawer(
              showOnlyMineCallback: () {
                setState(() {
                  _isShowingAllCharacters = false;
                  _isShowingParty = false;
                });
              },
              showAllCallback: () {
                setState(() {
                  _isShowingAllCharacters = true;
                  _isShowingParty = false;
                });
              },
              parties: drawerParties,
            )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (AuthManager.instance.isSignedIn) {
            showAddCharacterDialog();
          } else {
            showPleaseSignInDialog();
          }
        },
        tooltip: "Add a Character",
        child: const Icon(Icons.add),
      ),
    );
  }

  void showPleaseSignInDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Login required"),
          content: const Text(
              "You must be signed in to post.  Would you like to sign in now?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginFrontPage(),
                  ),
                );
              },
              child: const Text("Go to Login Page"),
            ),
          ],
        );
      },
    );
  }

  void showAddCharacterDialog() {
    showDialog(
        context: context,
        builder: (context) {
          nameTextController.text = "";
          classTextController.text = "";
          levelTextController.text = "";
          return CharacterDialog(
            nameTextController: nameTextController,
            classTextController: classTextController,
            levelTextController: levelTextController,
            positiveActionCallback: () {
              if (levelTextController.text == null) {
                return;
              }

              if (int.tryParse(levelTextController.text) == null) {
                return;
              }

              CharacterCollectionManager.instance.add(
                name: nameTextController.text,
                characterClass: classTextController.text,
                level: int.parse(levelTextController.text),
              );
            },
          );
        });
  }

  void showAddPartyDialog() {
    showDialog(
        context: context,
        builder: (context) {
          partyTextController.text = "";
          return AlertDialog(
            title: const Text("Enter Party Name"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: partyTextController,
                  decoration: const InputDecoration(
                    labelText: "Name:",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  PartyCollectionManager.instance.add(
                    name: partyTextController.text,
                    characters: selectedDocuments,
                  );
                  _isSelecting = false;
                  Navigator.pop(context);
                },
                child: const Text("Submit"),
              ),
            ],
          );
        });
  }
}
