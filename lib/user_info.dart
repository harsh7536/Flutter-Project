import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trendtalks/comment_section.dart';
import 'package:trendtalks/custom_snackbar.dart';
import 'package:trendtalks/select_community.dart';
import 'package:image_picker/image_picker.dart';

class UserInfoPage extends StatefulWidget {
  final String email;
  const UserInfoPage({super.key, required this.email});

  @override
  State createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final usernameController = TextEditingController();
  final aboutController = TextEditingController();
  XFile? profileImage;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> uploadImage({required String fileName}) async {
    log("Add image to firrebase");
    await FirebaseStorage.instance.ref().child(fileName).putFile(
          File(profileImage!.path),
        );
  }

  Future<String> downloadImageUrl({required String fileName}) async {
    log("GetUrl to firebase");
    String url =
        await FirebaseStorage.instance.ref().child(fileName).getDownloadURL();
    log("$url");
    return url;
  }

  // Future<bool> isUsernameTaken(String username) async {
  //   DocumentSnapshot doc = await FirebaseFirestore.instance
  //       .collection("Users")
  //       .doc(widget.email)
  //       .get();
  //   return doc.exists;
  // }
bool isloading = false;
  @override
  Widget build(BuildContext context) {
    log("${widget.email}");
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
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Set Up Your Profile",
                          style: GoogleFonts.pacifico(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 25),

                        GestureDetector(
                          onTap: () async {
                            profileImage = await _imagePicker.pickImage(
                                source: ImageSource.gallery);

                            if (profileImage != null) {
                              setState(() {});
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              image: profileImage == null
                                  ? null
                                  : DecorationImage(
                                      image:
                                          FileImage(File(profileImage!.path)),
                                      fit: BoxFit.cover),
                            ),
                            child: profileImage == null
                                ? const Icon(Icons.add_a_photo,
                                    color: Colors.white, size: 40)
                                : null,
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
                            controller: usernameController,
                            decoration: const InputDecoration(
                              labelText: "Username",
                              border: InputBorder.none,
                              hintText: "Enter your username",
                              icon: Icon(Icons.person, color: Colors.redAccent),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // About TextField
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
                            controller: aboutController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: "About You",
                              border: InputBorder.none,
                              hintText: "Tell us a bit about yourself",
                              icon: Icon(Icons.info, color: Colors.redAccent),
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
                            if (usernameController.text.trim().isNotEmpty &&
                                aboutController.text.trim().isNotEmpty) {
                                  setState(() {
                                    isloading = true;
                                  });
                              String fileName = profileImage!.name +
                                  DateTime.now().toString();
                              await uploadImage(fileName: fileName);
                              String url =
                                  await downloadImageUrl(fileName: fileName);
                              Map<String, dynamic> data = {
                                "username": usernameController.text.trim(),
                                "email": widget.email,
                                "about": aboutController.text.trim(),
                                "profilepic": url,
                                "timestamp": FieldValue.serverTimestamp(),
                                "followers": [],
                                "following": [],
                                "joinedcommunity": [],
                                "Myposts": [],
                                "myComments": [],
                                "bookmark": []
                              };
                              await FirebaseFirestore.instance
                                  .collection("Users")
                                  .doc(widget.email)
                                  .set(data);
                              log("user created_____________________________________");
                                 isloading = false;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CommunitySelectionPage(
                                          email: widget.email,
                                        )),
                              );
                            } else {
                              CustomSnackbar.showCustomSnackBar(
                                  message: "Enter valid fields",
                                  context: context);
                            }
                          },
                          child:isloading? 
                         const SizedBox(
                          height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                            
                            ),
                          ) :const Text(
                            "Save",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
