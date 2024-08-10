import 'package:ai_diary/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewPerson extends StatefulWidget {
  final Map<String, dynamic> people;
  const NewPerson({super.key, required this.people});

  @override
  _NewPersonState createState() => _NewPersonState();
}

class _NewPersonState extends State<NewPerson> {
  final TextEditingController _nameController = TextEditingController();
  User user = FirebaseAuth.instance.currentUser!;
  FirebaseFirestore db = FirebaseFirestore.instance;

  List personalityTraits = [
    "Shaper",
    "Mentor",
    "Pioneer",
    "Broker",
    "Achiever",
    "Director",
    "Anchor",
    "Analyst"
  ];
  List personalityDescriptions = [
    "The Shaper encourages cooperation and teamwork.",
    "Mentors are engaged in the development of people through a caring and compassionate approach.",
    "Pioneers enable change and adaptation, and pay attention to the changing environment.",
    "Brokers enjoy making new contacts and maintaining existing relations.",
    "Achievers are task-oriented and focused on work. They make high demands of themselves and others.",
    "Directors are long term thinkers, focused on the future. They will seek to clarify expectations through planning.",
    "The Anchor maintains the structure and flow in a system. They are trustworthy and reliable.",
    "Analysts know what is happening by breaking problems apart to see all the alternatives."
  ];
  int choosenPeronality = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(
                "New Person",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(label: Text("Name")),
                  onTapOutside: (event) {
                    unFocusKeyboard();
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  decoration: BoxDecoration(
                      color: Theme.of(context).focusColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: PopupMenuButton(
                      child: Column(
                        children: [
                          const Text(
                            "Choose your personality",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                          if (choosenPeronality == -1)
                            ...[]
                          else ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      personalityTraits[choosenPeronality],
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                      textAlign: TextAlign.start,
                                    )),
                                Expanded(
                                    flex: 5,
                                    child: Text(
                                      personalityDescriptions[
                                          choosenPeronality],
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                      textAlign: TextAlign.justify,
                                    ))
                              ],
                            )
                          ]
                        ],
                      ),
                      itemBuilder: (context) {
                        return [
                          for (String personality in personalityTraits) ...[
                            PopupMenuItem(
                                onTap: () {
                                  setState(() {
                                    choosenPeronality =
                                        personalityTraits.indexOf(personality);
                                  });
                                },
                                child: Text(personality))
                          ]
                        ];
                      }),
                ),
                const SizedBox(
                  height: 20,
                ),
                submit()
              ],
            ),
          ),
        ));
  }

  void createPerson() async {
    String name = _nameController.text;
    if (name == "" || name.isEmpty) {
      Utils.showSnackBar("Error: Write a name");
      return;
    }

    db
        .collection("users")
        .doc(user.email!)
        .collection("people")
        .doc(_nameController.text)
        .set(
            {"dates": [], "personality": personalityTraits[choosenPeronality]});
    Navigator.pop(context);
  }

  Widget submit() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: GestureDetector(
            onTap: createPerson,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              decoration: BoxDecoration(
                  color: Theme.of(context).focusColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                "Create",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
