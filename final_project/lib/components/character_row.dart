import 'package:final_project/model/character.dart';
import 'package:flutter/material.dart';

class CharacterRow extends StatelessWidget {
  final Character character;
  final void Function() onTapCallback;
  final bool selectState;
  final selectedIds;

  const CharacterRow({
    super.key,
    required this.character,
    required this.onTapCallback,
    required this.selectState,
    required this.selectedIds,
  });

  @override
  Widget build(BuildContext context) {
    var iconUsed = Icon(Icons.person);

    if (selectState) {
      if (selectedIds.contains(character.documentId)) {
        iconUsed = Icon(Icons.check_box);
      } else {
        iconUsed = Icon(Icons.check_box_outline_blank);
      }
    }

    return ListTile(
      onTap: onTapCallback,
      leading: iconUsed,
      title: Text(
        character.name,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        "Level " + character.level.toString() + " " + character.characterClass,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
