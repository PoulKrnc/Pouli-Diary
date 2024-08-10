import 'package:ai_diary/page/day_page.dart';
import 'package:ai_diary/page/delete_person.dart';
import 'package:intl/intl.dart';

import 'package:ai_diary/page/new_entry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  User user = FirebaseAuth.instance.currentUser!;

  Map<String, dynamic> people = {};
  String? selectedPerson;

  void getData() async {
    await db
        .collection("users")
        .doc(user.email)
        .collection("people")
        .get()
        .then((documents) async {
      setState(() {
        people = {};
      });
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in documents.docs) {
        people.addAll({doc.id: doc.data()});
        selectedPerson ??= doc.id;
      }
    });
    if (selectedPerson == null) {
      setState(() {});
      return;
    }
    setState(() {});
  }

  void newEntry() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return NewEntry(
        initialPerson: selectedPerson,
      );
    })).then((value) {
      getData();
      setState(() {});
    });
  }

  void logOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 5, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                    child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  decoration: const BoxDecoration(),
                  child: Row(
                    children: [
                      Text(
                        user.email!,
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 18),
                      ),
                    ],
                  ),
                )),
                GestureDetector(
                    onTap: logOut,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      decoration: const BoxDecoration(),
                      child: const Row(
                        children: [
                          Icon(Icons.logout),
                          Text(
                            "Log out",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 18),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          "AI Diary",
          style: Theme.of(context).textTheme.displaySmall,
        ),
        actions: [
          Container(
            width: 60,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: newEntry,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      13), /*border: Border.all(color: Theme.of(context).focusColor)*/
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          /*color: Theme.of(context).secondaryHeaderColor,*/
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(13),
                              topRight: Radius.circular(13))),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 3, 20, 3),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                personChoose();
                              },
                              child: Row(
                                children: [
                                  Text(
                                    selectedPerson ?? "Loading",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Theme.of(context).primaryColor),
                                  ),
                                  const Icon(Icons.arrow_drop_down_outlined)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(child: stream())
                  ],
                ),
              ))),
    );
  }

  Widget stream() {
    return StreamBuilder(
        stream: db
            .collection("users")
            .doc(user.email)
            .collection("people")
            .doc(selectedPerson)
            .collection("dates")
            .orderBy("date", descending: true)
            .snapshots(),
        builder: (context, snapshots) {
          if (snapshots.data == null || snapshots.data!.size == 0) {
            return Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    newEntry();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Add your first entry ",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        "here",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: Colors.blue),
                      )
                    ],
                  ),
                )
              ],
            );
          }
          List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
              snapshots.data!.docs;
          return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var doc = docs[index];
                Timestamp t = doc["date"];
                DateTime time = DateTime.fromMillisecondsSinceEpoch(
                    t.millisecondsSinceEpoch);
                String text = doc["text"];
                text = text.substring(0, 50).replaceAll("\n", " ");
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return DayPage(
                            text: doc["text"],
                            timestamp: t,
                            id: doc.id,
                            tag: DateFormat("dd.MM.yyyy").format(time),
                            person: selectedPerson!,
                          );
                        })).then((value) {
                          setState(() {});
                          getData();
                        });
                      },
                      child: Hero(
                        tag: DateFormat("dd.MM.yyyy").format(time),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                DateFormat("dd.MM.yyyy").format(time),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        color: Theme.of(context).primaryColor),
                              ),
                            ),
                            Expanded(
                                flex: 4,
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          left: BorderSide(
                                              color: Theme.of(context)
                                                  .focusColor))),
                                  child: Text(
                                    text,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                )),
                            const Expanded(
                                child: Icon(Icons.arrow_forward_ios_outlined))
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
        });
  }

  void personChoose() async {
    SelectedPerson p = SelectedPerson(selectedPerson);
    await showDialog(
        context: context,
        builder: (context) {
          return DeletePerson(
            selectedPerson: p,
            people: people,
          );
        }).then((_) {
      setState(() {});
    });
    setState(() {
      selectedPerson = p.selectedPerson;
      getData();
    });
  }
}

class SelectedPerson {
  String? selectedPerson;
  SelectedPerson(this.selectedPerson);
}
