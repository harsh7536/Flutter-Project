import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trendtalks/custom_snackbar.dart';
import 'homescreen.dart';

class CreatePostPage extends StatefulWidget {
  Map<String, dynamic> userdata;
  CreatePostPage({super.key, required this.userdata});

  @override
  State createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  String? profileurl;
  bool isloading = false;
  Future<void> getProfileUrl(String select) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('Community').doc(select);
    try {
      
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        profileurl = docSnapshot.get('profilepic');
        log('Field value: $profileurl');
      } else {
        log('Document does not exist');
      }
    } catch (e) {
      log('Error fetching document: $e');
    }
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<XFile>? profileImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  String selectedCommunity = "Select Community";

  List<String> imageUrl = [];
  List<String> fileNames = [];
  Future<void> uploadImages() async {
    
    for (var image in profileImages!) {
      String fileName = image.name + DateTime.now().toString();
      fileNames.add(fileName); 
      await FirebaseStorage.instance.ref().child(fileName).putFile(
            File(image.path),
          );
    }

    
    imageUrl = await downloadImageUrls(fileNames);
  }


  Future<List<String>> downloadImageUrls(List<String> fileNames) async {
    List<String> urls = [];
    for (var fileName in fileNames) {
      String url =
          await FirebaseStorage.instance.ref().child(fileName).getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  List<String> joinedcomunitylist = [];
  @override
  void initState() {
    super.initState();
    joinedcomunitylist = widget.userdata["joinedcommunity"].cast<String>();
    if (!joinedcomunitylist.contains("Select Community")) {
      joinedcomunitylist.insert(0, "Select Community");
    }
    log("$joinedcomunitylist");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Create Post",
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
            Text(
              "Title",
              style: GoogleFonts.roboto(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintText: "Enter the title",
                hintStyle: const TextStyle(color: Colors.white60),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              "Description",
              style: GoogleFonts.roboto(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintText: "Write a description...",
                hintStyle: const TextStyle(color: Colors.white60),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              "Pictures (optional)",
              style: GoogleFonts.roboto(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                profileImages = await _imagePicker.pickMultiImage();

                if (profileImages!.isNotEmpty) {
                  setState(() {});
                }
              },
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: const Color.fromRGBO(70, 70, 73, 1.0)),
                ),
                child: profileImages!.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: profileImages!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Image.file(
                                          File(profileImages![index].path)),
                                      GestureDetector(
                                        onTap: () {
                                          profileImages!.removeAt(index);
                                          log("Removed image $index");
                                          setState(() {});
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          height: 16,
                                          width: 16,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red),
                                          child: const Icon(
                                            Icons.remove,
                                            size: 16,
                                          ),
                                        ),
                                      )
                                    ]),
                              );
                            }),
                      )
                    : Center(
                        child: Text(
                          "Tap to select an image",
                          style: GoogleFonts.roboto(
                              color: Colors.white60, fontSize: 14),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              "Select Community",
              style: GoogleFonts.roboto(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white30),
              ),
              child: DropdownButton<String>(
                menuMaxHeight: 200,
                value: selectedCommunity,
                dropdownColor: const Color.fromRGBO(36, 36, 38, 1.0),
                iconEnabledColor: Colors.white,
                isExpanded: true,
                style: GoogleFonts.roboto(color: Colors.white),
                underline: const SizedBox(),
                items: joinedcomunitylist.map((String community) {
                  return DropdownMenuItem<String>(
                    value: community,
                    child: Text(community,
                        style: GoogleFonts.roboto(color: Colors.white70)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCommunity = newValue!;
                  });
                },
              ),
            ),
            const Spacer(),

            // Post Button
            GestureDetector(
              onTap: () async {
                
                if (_titleController.text.trim().isNotEmpty &&
                    _descriptionController.text.trim().isNotEmpty &&
                    selectedCommunity != "Select Community") {
                      setState(() {
                  isloading = true;
                });
                  if (profileImages!.isNotEmpty) {
                    await uploadImages();
                    log("images uploaded and downloaded");
                  }
                  await getProfileUrl(selectedCommunity);

                  Map<String, dynamic> data = {
                    "title": _titleController.text.trim(),
                    "description": _descriptionController.text.trim(),
                    "pictures": imageUrl.isNotEmpty ? imageUrl : "",
                    "timestamp": FieldValue.serverTimestamp(),
                    "createdby": widget.userdata["email"],
                    "comments": [],
                    "community": selectedCommunity,
                    "like": [],
                    "dislike": [],
                    "username": widget.userdata["username"],
                    "communitypic": profileurl,
                    "support": ""
                  };
                  log("$data");
                  DocumentReference postRef = await FirebaseFirestore.instance
                      .collection("Posts")
                      .add(data);
                  String postId = postRef.id;
                  log(postId);
                  await FirebaseFirestore.instance
                      .collection("Posts")
                      .doc(postId)
                      .update({
                    "postId": postId, // Add the new field with its value
                  });
                  await FirebaseFirestore.instance
                      .collection("Users")
                      .doc(widget.userdata["email"])
                      .update({
                    "Myposts": FieldValue.arrayUnion([postId])
                  });
                  await FirebaseFirestore.instance
                      .collection("Community")
                      .doc(selectedCommunity)
                      .update({
                    "Posts": FieldValue.arrayUnion([postId])
                  });
                   isloading = false;
                  Navigator.pop(context);
                  CustomSnackbar.showCustomSnackBar(
                      message: "Post Created Successfully", context: context);
                } else {
                  CustomSnackbar.showCustomSnackBar(
                      message: "Enter required fields", context: context);
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(139, 0, 0, 1.0),
                      Color.fromRGBO(178, 34, 34, 1.0)
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
                  child: isloading? 
                 const SizedBox(
                  height: 20,
                    width: 20,
                    child: CircularProgressIndicator()):Text(
                    "Post",
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
