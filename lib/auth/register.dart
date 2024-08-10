// ignore_for_file: avoid_unnecessary_containers

import 'package:ai_diary/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLogInPage;
  const RegisterPage({super.key, required this.showLogInPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordVisible = true;
  bool _confirmpasswordVisible = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future signUp() async {
    final isValid = formKey.currentState!.validate();
    if (isValid) {
      if (_passwordController.text.trim() ==
          _confirmPasswordController.text.trim()) {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim());
        } on FirebaseAuthException catch (e) {
          Utils.showSnackBar(e.message);
        }
      } else {
        Utils.showSnackBar("Passwords do not match.");
      }
    } else {
      Utils.showSnackBar("Something went wrong.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Register",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 33,
                          color: Colors.blue),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      margin:
                          const EdgeInsetsDirectional.fromSTEB(25, 5, 25, 5),
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        cursorColor: Colors.black,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.grey.shade700),
                            border: InputBorder.none,
                            hintText: "Email"),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (email) =>
                            email != null && !EmailValidator.validate(email)
                                ? "Enter a valid email"
                                : null,
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsetsDirectional.fromSTEB(25, 5, 25, 5),
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        cursorColor: Colors.black,
                        style: const TextStyle(color: Colors.black),
                        obscureText: _passwordVisible,
                        decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.grey.shade700),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                              icon: Icon(_passwordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                            ),
                            border: InputBorder.none,
                            hintText: "Password"),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) => value != null && value.length < 8
                            ? "Enter min. 8 caracters"
                            : null,
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsetsDirectional.fromSTEB(25, 5, 25, 5),
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _confirmPasswordController,
                        cursorColor: Colors.black,
                        style: const TextStyle(color: Colors.black),
                        obscureText: _confirmpasswordVisible,
                        decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.grey.shade700),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _confirmpasswordVisible =
                                      !_confirmpasswordVisible;
                                });
                              },
                              icon: Icon(_confirmpasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                            ),
                            border: InputBorder.none,
                            hintText: "Confirm Password"),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                        child: Center(
                      child: Row(
                        children: [
                          const Spacer(),
                          GestureDetector(
                            onTap: widget.showLogInPage,
                            child: Container(
                                margin: const EdgeInsets.all(5),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    "Log In",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey[800]),
                                  ),
                                )),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: signUp,
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                        offset: Offset(2, 2),
                                        blurRadius: 5,
                                        color: Colors.grey)
                                  ]),
                              child: Center(
                                child: Text(
                                  "Sign Up",
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800]),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ))
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
