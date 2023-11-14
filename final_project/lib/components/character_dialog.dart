import 'package:flutter/material.dart';

class CharacterDialog extends StatelessWidget {
  final TextEditingController nameTextController;
  final TextEditingController classTextController;
  final TextEditingController levelTextController;
  final void Function() positiveActionCallback;
  final bool isEditDialog;

  const CharacterDialog({
    super.key,
    required this.nameTextController,
    required this.classTextController,
    required this.levelTextController,
    required this.positiveActionCallback,
    this.isEditDialog = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditDialog ? "Edit this Character" : "Create a Character"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: nameTextController,
            decoration: const InputDecoration(
              labelText: "Name:",
            ),
          ),
          TextFormField(
            controller: classTextController,
            decoration: const InputDecoration(
              labelText: "Class:",
            ),
          ),
          TextFormField(
            controller: levelTextController,
            decoration: const InputDecoration(
              labelText: "Level:",
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
            positiveActionCallback();
            Navigator.pop(context);
          },
          child: const Text("Submit"),
        ),
      ],
    );
  }
}
