import 'dart:async';

import 'package:final_project/components/character_dialog.dart';
import 'package:final_project/components/display_card.dart';
import 'package:final_project/managers/character_document_manager.dart';
import 'package:final_project/managers/character_collection_manager.dart';
import 'package:flutter/material.dart';

class CharacterDetailPage extends StatefulWidget {
  final String documentId;

  const CharacterDetailPage(
    this.documentId, {
    super.key,
  });

  @override
  State<CharacterDetailPage> createState() => _CharacterDetailPageState();
}

class _CharacterDetailPageState extends State<CharacterDetailPage> {
  final nameTextController = TextEditingController();
  final classTextController = TextEditingController();
  final levelTextController = TextEditingController();
  StreamSubscription? characterSubscription;

  @override
  void initState() {
    CharacterDocumentManager.instance.startListening(
      documentId: widget.documentId,
      observer: () {
        print("Got the character!");
        setState(() {});
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    nameTextController.dispose();
    classTextController.dispose();
    levelTextController.dispose();
    CharacterDocumentManager.instance.stopListening(characterSubscription);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];
    if (CharacterDocumentManager.instance.latestCharacter != null) {
      actions = [
        IconButton(
          onPressed: () {
            showEditDialog();
          },
          icon: const Icon(Icons.edit),
        ),
        IconButton(
          onPressed: () {
            String tempName =
                CharacterDocumentManager.instance.latestCharacter!.name;
            String tempClass = CharacterDocumentManager
                .instance.latestCharacter!.characterClass;
            int tempLevel =
                CharacterDocumentManager.instance.latestCharacter!.level;
            CharacterDocumentManager.instance.delete();

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text("Character Deleted"),
              action: SnackBarAction(
                label: "Undo",
                onPressed: () {
                  CharacterCollectionManager.instance.add(
                    name: tempName,
                    characterClass: tempClass,
                    level: tempLevel,
                  );
                },
              ),
            ));
            Navigator.pop(context);
          },
          icon: const Icon(Icons.delete),
        ),
      ];
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Character"),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: actions,
        ),
        backgroundColor: Colors.black12,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              DisplayCard(
                title: "Name:",
                iconData: Icons.person,
                cardText:
                    CharacterDocumentManager.instance.latestCharacter?.name ??
                        "",
              ),
              DisplayCard(
                title: "Class:",
                iconData: Icons.star,
                cardText: CharacterDocumentManager
                        .instance.latestCharacter?.characterClass ??
                    "",
              ),
              DisplayCard(
                title: "Level:",
                iconData: Icons.numbers,
                cardText: CharacterDocumentManager
                        .instance.latestCharacter?.level
                        .toString() ??
                    "",
              ),
            ],
          ),
        ));
  }

  void showEditDialog() {
    showDialog(
        context: context,
        builder: (context) {
          nameTextController.text =
              CharacterDocumentManager.instance.latestCharacter?.name ?? "";
          classTextController.text = CharacterDocumentManager
                  .instance.latestCharacter?.characterClass ??
              "";

          levelTextController.text = CharacterDocumentManager
                  .instance.latestCharacter?.level
                  .toString() ??
              "";

          return CharacterDialog(
            nameTextController: nameTextController,
            classTextController: classTextController,
            levelTextController: levelTextController,
            isEditDialog: true,
            positiveActionCallback: () {
              if (levelTextController.text == null) {
                return;
              }

              if (int.tryParse(levelTextController.text) == null) {
                return;
              }
              CharacterDocumentManager.instance.update(
                name: nameTextController.text,
                characterClass: classTextController.text,
                level: int.parse(levelTextController.text),
              );
            },
          );
        });
  }
}
