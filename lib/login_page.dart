import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trendtalks/custom_snackbar.dart';
import 'package:trendtalks/homescreen.dart';
import 'package:trendtalks/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isObscured = true;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool isloading = false;

  Map<String, dynamic> userdata = {};

  Future<void> addDatatoMap(String email) async {
    try {
      DocumentSnapshot documentSnapshot =
          await FirebaseFirestore.instance.collection("Users").doc(email).get();
      log("sfbfsbfdbfdzbdfbdbbzdbfzdb");
      userdata = documentSnapshot.data() as Map<String, dynamic>;
      log(userdata["username"]);
    } catch (e) {
      log("Erroe while fetch");
    }
  }
 

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Color.fromARGB(255, 247, 40, 40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 22, 5, 5),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome Back!",
                      style: GoogleFonts.pacifico(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: InputBorder.none,
                          hintText: "Enter your email",
                          icon: Icon(Icons.email, color: Colors.redAccent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: passwordController,
                        obscureText: isObscured,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: InputBorder.none,
                          hintText: "Enter your password",
                          icon: const Icon(Icons.lock, color: Colors.redAccent),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isObscured
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              setState(() {
                                isObscured = !isObscured;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 30),
                      ),
                      onPressed: () async {
                        if (emailController.text.trim().isNotEmpty &&
                            passwordController.text.trim().isNotEmpty) {
                              setState(() {
                                isloading = true;
                              });
                          try {
                            UserCredential userCredential =
                                await _firebaseAuth.signInWithEmailAndPassword(
                                    email: emailController.text,
                                    password: passwordController.text);
                            log("${userCredential.user!.email}");
                            await addDatatoMap(emailController.text.trim());
                            log("$userdata");
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen(
                                          userdata: userdata,
                                        )),
                                (Route<dynamic> route) => false);
                          } on FirebaseAuthException catch (error) {
                            log("${error.code}");
                            CustomSnackbar.showCustomSnackBar(
                                message: "${error.code}", context: context);
                          }
                          isloading = false;
                        }
                      },
                      child:isloading ?  
                     const  SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator()): const Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          const TextSpan(
                            text: "Don\'t have an account? ",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                              text: "Sign up",
                              style: const TextStyle(
                                color: Colors.black,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SignupPage()),
                                      (Route<dynamic> route) => false);
                                }),
                        ],
                      ),
                    ),
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
