import 'package:ai_diary/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import "package:intl/intl.dart";

class DayPage extends StatefulWidget {
  final String tag;
  final String text;
  final Timestamp timestamp;
  final String id;
  final String person;
  const DayPage(
      {super.key,
      required this.tag,
      required this.text,
      required this.timestamp,
      required this.id,
      required this.person});

  @override
  _DayPageState createState() => _DayPageState();
}

class _DayPageState extends State<DayPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  User user = FirebaseAuth.instance.currentUser!;
  final TextEditingController _textController = TextEditingController();
  bool editMode = false;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.text;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat("dd.MM.yyyy").format(
            DateTime.fromMillisecondsSinceEpoch(
                widget.timestamp.millisecondsSinceEpoch))),
      ),
      floatingActionButton: GestureDetector(
        onTap: () async {
          if (editMode) {
            setState(() {
              editMode = false;
            });
            Utils.showSnackBar("Entry Updated");
            await db
                .collection("users")
                .doc(user.email)
                .collection("people")
                .doc(widget.person)
                .collection("dates")
                .doc(widget.id)
                .update({"text": _textController.text});
            unFocusKeyboard();
            Navigator.pop(context);
          } else {
            Utils.showSnackBar("Edit mode");
            setState(() {
              editMode = true;
            });
          }
        },
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 1000),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: !editMode
                    ? Theme.of(context).dividerColor
                    : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10)),
            child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: editMode
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).canvasColor,
                      )
                    : Icon(
                        Icons.edit,
                        color: Theme.of(context).canvasColor,
                      ))),
      ),
      body: SafeArea(
        child: Hero(
          tag: widget.tag,
          child: Material(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 1),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      onTapOutside: (event) {
                        unFocusKeyboard();
                      },
                      readOnly: !editMode,
                      maxLines: 500,
                      minLines: 1,
                      controller: _textController,
                    ),
                    const SizedBox(
                      height: 200,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
