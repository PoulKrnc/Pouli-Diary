// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:ai_diary/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart' as g;

class GeneratePage extends StatefulWidget {
  final String? person;
  final String prompt;
  final DateTime date;
  const GeneratePage(
      {super.key,
      required this.person,
      required this.date,
      required this.prompt});

  @override
  // ignore: library_private_types_in_public_api
  _GeneratePageState createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  User user = FirebaseAuth.instance.currentUser!;
  final gemini = g.Gemini.instance;
  final TextEditingController _textController = TextEditingController();
  String product = "";
  bool generating = true;
  Map<String, dynamic> personData = {};

  void generatePrompt() async {
    String prompt =
        "From this draft, write the text for one day in ${widget.person}'s diary on ${widget.date.toString()}: '${widget.prompt}'. Write it base on his/hers personality which is: '${personData["personality"]}'. Compose the text as a part of the story where story is a whole diary together and DO NOT split the text by hours ";
    log(prompt);
    try {
      gemini.streamGenerateContent(prompt).listen((value) {
        setState(() {
          generating = false;
          _textController.text += value.output!;
        });
        log(product);
      }).onDone(() {
        setState(() {
          generating = false;
        });
      });
    } catch (e) {
      log(e.toString());
    }
  }

  void loadData() async {
    await db
        .collection("users")
        .doc(user.email)
        .collection("people")
        .doc(widget.person)
        .get()
        .then(
      (value) {
        personData =
            value.data() ?? {"personality": "Normal person", "dates": []};
      },
    );
    generatePrompt();
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Generated Text",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      floatingActionButton: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(),
            const SizedBox(),
            const SizedBox(),
            const SizedBox(),
            const SizedBox(),
            const SizedBox(),
            FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  generating = true;
                });
                generatePrompt();
              },
              label: const Text("Generate Again"),
            ),
            FloatingActionButton.extended(
                onPressed: () async {
                  Timestamp timestamp = Timestamp.fromDate(widget.date);
                  personData["dates"].add(timestamp);
                  await db
                      .collection("users")
                      .doc(user.email)
                      .collection("people")
                      .doc(widget.person)
                      .update({"dates": personData["dates"]});
                  await db
                      .collection("users")
                      .doc(user.email)
                      .collection("people")
                      .doc(widget.person)
                      .collection("dates")
                      .doc(timestamp.seconds.toString())
                      .set({"text": _textController.text, "date": timestamp});
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                label: const Text("Submit"))
          ],
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Container(
            child: generating
                ? const Center(
                    child: LoadingIndicatorFb1(),
                  )
                : TextField(
                    onTapOutside: (event) {
                      unFocusKeyboard();
                    },
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 500,
                    controller: _textController,
                  ),
          ),
        ),
      )),
    );
  }
}

class LoadingIndicatorFb1 extends StatelessWidget {
  const LoadingIndicatorFb1({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
  }
}
