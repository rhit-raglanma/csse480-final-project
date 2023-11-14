import 'package:final_project/managers/auth_manager.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

class ListPageDrawer extends StatelessWidget {
  final void Function() showOnlyMineCallback;
  final void Function() showAllCallback;
  // final void Function() showPartyCallback;
  final FirestoreListView? parties;

  const ListPageDrawer({
    super.key,
    required this.showOnlyMineCallback,
    required this.showAllCallback,
    // required this.showPartyCallback,
    required this.parties,
  });

  @override
  Widget build(BuildContext context) {
    print("DRAWER HERE");
    print(parties == null);

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: const Text(
              "Party Manager",
              style: TextStyle(color: Colors.white, fontSize: 28.0),
            ),
          ),
          ListTile(
            title: Text("Show only my characters"),
            leading: Icon(Icons.person),
            onTap: () {
              Navigator.of(context).pop();
              showOnlyMineCallback();
            },
          ),
          ListTile(
            title: Text("Show all characters"),
            leading: Icon(Icons.people),
            onTap: () {
              Navigator.of(context).pop();
              showAllCallback();
            },
          ),
          // ListTile(
          //   title: Text("Show my party"),
          //   leading: Icon(Icons.people),
          //   onTap: () {
          //     Navigator.of(context).pop();
          //     showPartyCallback();
          //   },
          // ),
          parties == null
              ? const SizedBox(
                  height: 0,
                )
              : parties!,
          const Spacer(),
          const Divider(
            thickness: 2.0,
          ),
          ListTile(
            title: Text("Logout"),
            leading: Icon(Icons.logout),
            onTap: () {
              Navigator.of(context).pop();
              AuthManager.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
