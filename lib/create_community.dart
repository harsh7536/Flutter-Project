import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trendtalks/custom_snackbar.dart';

class CreateCommunityPage extends StatefulWidget {
  Map<String, dynamic> userdata;
  CreateCommunityPage({super.key, required this.userdata});

  @override
  State createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rulesController = TextEditingController();
  bool isloading = false;

  //String profileImageUrl = "";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Create Community",
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        foregroundColor: Colors.white54,
        backgroundColor: const Color.fromRGBO(26, 26, 27, 1.0),
      ),
      backgroundColor: const Color.fromRGBO(24, 24, 27, 1.0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Community Name
            Text(
              "Community Name",
              style: GoogleFonts.roboto(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintText: "Enter community name",
                hintStyle: const TextStyle(color: Colors.white60),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              "Description",
              style: GoogleFonts.roboto(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintText: "Describe your community...",
                hintStyle: const TextStyle(color: Colors.white60),
              ),
            ),
            const SizedBox(height: 16),

            // Rules
            Text(
              "Rules",
              style: GoogleFonts.roboto(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _rulesController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintText: "Set rules for the community...",
                hintStyle: const TextStyle(color: Colors.white60),
              ),
            ),
            const SizedBox(height: 16),

            // Profile Picture
            Text(
              "Profile Picture",
              style: GoogleFonts.roboto(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                profileImage =
                    await _imagePicker.pickImage(source: ImageSource.gallery);

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
                          image: FileImage(File(profileImage!.path)),
                          fit: BoxFit.cover),
                ),
                child: profileImage == null
                    ? const Icon(Icons.add_a_photo,
                        color: Colors.white, size: 40)
                    : null,
              ),
            ),
            const Spacer(),

            // Create Button
            GestureDetector(
              onTap: () async {
                if (_nameController.text.trim().isNotEmpty &&
                    _descriptionController.text.trim().isNotEmpty &&
                    _rulesController.text.trim().isNotEmpty) {
                      setState(() {
                        isloading = true;
                      });
                  String fileName =
                      profileImage!.name + DateTime.now().toString();
                  await uploadImage(fileName: fileName);
                  String url = await downloadImageUrl(fileName: fileName);
                  Map<String, dynamic> data = {
                    "name": _nameController.text.trim(),
                    "description": _descriptionController.text.trim(),
                    "rules": _rulesController.text.trim(),
                    "profilepic": url,
                    "timestamp": FieldValue.serverTimestamp(),
                    "createdby": widget.userdata["email"],
                    "members": [],
                    "Posts": []
                  };
                  await FirebaseFirestore.instance
                      .collection("Community")
                      .doc(_nameController.text.trim())
                      .set(data);
                  log("user created_____________________________________");
                  await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(widget.userdata["email"])
                      .update({
                    'joinedcommunity':
                        FieldValue.arrayUnion([_nameController.text.trim()])
                  });
                  await FirebaseFirestore.instance
                      .collection('Community')
                      .doc(_nameController.text.trim())
                      .update({
                    'members': FieldValue.arrayUnion([widget.userdata["email"]])
                  });
                  CustomSnackbar.showCustomSnackBar(message: "Community Created Successfully",context: context);
                  isloading = false;
                  Navigator.pop(context);
                } else {
                   CustomSnackbar.showCustomSnackBar(message: "Enter valid fields", context: context);
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(139, 0, 0, 1.0),
                      Color.fromRGBO(178, 34, 34, 1.00),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(3, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child:isloading? 
                 const SizedBox(
                height: 20,
                    width: 20,
                    child: CircularProgressIndicator()):Text(
                    "Create",
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
