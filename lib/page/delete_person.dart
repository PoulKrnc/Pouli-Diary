import 'package:ai_diary/page/home_page.dart';
import 'package:ai_diary/page/new_person.dart';
import 'package:ai_diary/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DeletePerson extends StatefulWidget {
  final Map<String, dynamic> people;
  final SelectedPerson selectedPerson;
  const DeletePerson(
      {super.key, required this.people, required this.selectedPerson});

  @override
  _DeletePersonState createState() => _DeletePersonState();
}

class _DeletePersonState extends State<DeletePerson> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  User user = FirebaseAuth.instance.currentUser!;
  bool delete = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Center(
        child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Choose person",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(
                  height: 15,
                ),
                for (var entry in widget.people.entries) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            widget.selectedPerson.selectedPerson = entry.key;
                          });
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          entry.key,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).primaryColor),
                        ),
                      ),
                      if (delete) ...[
                        const SizedBox(
                          width: 15,
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (await showAlertDialog(
                                context,
                                "All the data will be lost.",
                                "Do you really wish to delete ${entry.key}?")) {
                              Navigator.pop(context);
                              await db
                                  .collection("users")
                                  .doc(user.email!)
                                  .collection("people")
                                  .doc(entry.key)
                                  .delete();
                              await Utils.showSnackBar("Deleted ${entry.key}");
                            }
                          },
                          child: const Icon(
                            Icons.delete_outline_outlined,
                            color: Colors.red,
                          ),
                        )
                      ]
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
                GestureDetector(
                  onTap: () async {
                    await Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return NewPerson(
                        people: widget.people,
                      );
                    })).then((value) {
                      setState(() {});
                      Navigator.pop(context);
                    });
                  },
                  child: Text("Create new",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontWeight: FontWeight.w500)),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      delete = !delete;
                    });
                  },
                  child: Text("Delete",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w500, color: Colors.red)),
                ),
              ],
            )),
      ),
    );
  }

  Future<bool> showAlertDialog(
      BuildContext context, String message, String title) async {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: const Text("Cancel"),
      onPressed: () {
        // returnValue = false;
        Navigator.of(context).pop(false);
      },
    );
    Widget continueButton = ElevatedButton(
      child: const Text("Continue"),
      onPressed: () {
        // returnValue = true;
        Navigator.of(context).pop(true);
      },
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        cancelButton,
        continueButton,
      ],
    ); // show the dialog
    final result = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    return result ?? false;
  }
}
