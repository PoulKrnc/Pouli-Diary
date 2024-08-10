import 'package:ai_diary/page/generate_page.dart';
import 'package:ai_diary/page/new_person.dart';
import 'package:ai_diary/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewEntry extends StatefulWidget {
  final String? initialPerson;
  const NewEntry({super.key, required this.initialPerson});

  @override
  _NewEntryState createState() => _NewEntryState();
}

class _NewEntryState extends State<NewEntry> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  User user = FirebaseAuth.instance.currentUser!;
  DateTime date = DateTime.now();
  Map<String, dynamic> people = {};
  String? selectedPerson;
  String errorMessage = "";
  final promptController = TextEditingController();

  void getData() async {
    date = DateTime(date.year, date.month, date.day);
    await db
        .collection("users")
        .doc(user.email)
        .collection("people")
        .get()
        .then((documents) async {
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in documents.docs) {
        people.addAll({doc.id: doc.data()});
        selectedPerson ??= doc.id;
      }
    });
    if (selectedPerson == null) {
      setState(() {});
      return;
    }
    errorMessage = "";
    for (Timestamp timestamp in people[selectedPerson]["dates"]) {
      if (Timestamp.fromDate(date).seconds == timestamp.seconds) {
        errorMessage = "Entry for this date already exists";
        break;
      } else {
        errorMessage = "";
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    selectedPerson = widget.initialPerson;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(
                "New Entry",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  errorMessage,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Colors.red),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [choosePerson(), chooseDate()],
                ),
                entry(),
                submit()
              ],
            ),
          ),
        ));
  }

  Widget submit() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return GeneratePage(
                  person: selectedPerson,
                  prompt: promptController.text,
                  date: date,
                );
              })).then((value) {
                setState(() {});
              });
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(25, 5, 25, 5),
              decoration: BoxDecoration(
                  color: Theme.of(context).splashColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                "Next",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget entry() {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          decoration: BoxDecoration(
              color: Theme.of(context).splashColor,
              borderRadius: BorderRadius.circular(10)),
          child: TextField(
            onTapOutside: (event) {
              unFocusKeyboard();
            },
            keyboardType: TextInputType.multiline,
            minLines: 3,
            maxLines: 18,
            controller: promptController,
          ),
        ),
      ),
    );
  }

  Widget choosePerson() {
    //CHOOSE PERSON WIDGET
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: GestureDetector(
          onTap: () async {
            await showDialog(
                context: context,
                builder: (context) {
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
                              for (var entry in people.entries) ...[
                                GestureDetector(
                                  onTap: () {
                                    selectedPerson = entry.key;
                                    for (Timestamp timestamp
                                        in people[selectedPerson]["dates"]) {
                                      if (Timestamp.fromDate(date).seconds ==
                                          timestamp.seconds) {
                                        errorMessage =
                                            "Entry for this date already exists";
                                        break;
                                      } else {
                                        errorMessage = "";
                                      }
                                    }
                                    setState(() {});
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    entry.key,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Theme.of(context).primaryColor),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                )
                              ],
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return NewPerson(people: people);
                                  })).then((value) {
                                    Navigator.of(context).pop();
                                    getData();
                                    setState(() {});
                                  });
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 2, 20, 2),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Theme.of(context).hoverColor),
                                  child: Text("Create new",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                              fontWeight: FontWeight.w500)),
                                ),
                              ),
                            ],
                          )),
                    ),
                  );
                });
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            decoration: BoxDecoration(
                color: Theme.of(context).splashColor,
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Text(
                  "Person: ",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  selectedPerson ?? "Loading",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget chooseDate() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: GestureDetector(
          onTap: () async {
            date = (await showDatePickerDialog(
                    context: context,
                    currentDate: date,
                    initialDate: date,
                    minDate: DateTime.now().subtract(const Duration(days: 10)),
                    maxDate: DateTime.now())) ??
                date;
            errorMessage = "";
            for (Timestamp timestamp in people[selectedPerson]["dates"]) {
              if (Timestamp.fromDate(date).seconds == timestamp.seconds) {
                errorMessage = "Entry for this date already exists";
                break;
              } else {
                errorMessage = "";
              }
            }
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            decoration: BoxDecoration(
                color: Theme.of(context).splashColor,
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Text(
                  "Date: ",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  DateFormat("dd.MM.yyyy").format(date),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
