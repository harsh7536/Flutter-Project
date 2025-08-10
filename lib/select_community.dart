import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homescreen.dart';
// Import your home screen here

class CommunitySelectionPage extends StatefulWidget {
  final String email;
  const CommunitySelectionPage({super.key, required this.email});

  @override
  State createState() => _CommunitySelectionPageState();
}

class _CommunitySelectionPageState extends State<CommunitySelectionPage> {
  List<Map<String, dynamic>> categories = [
    {
      "categoryName": "Technology",
      "communities": ["c_language", "flutter", "java"],
    },
    {
      "categoryName": "Sports",
      "communities": ["tennis", "cricket"],
    },
    {
      "categoryName": "Entertainment",
      "communities": ["movies", "pcgames", "music"],
    },
  ];
  

  
  Map<String, dynamic> userData = {};
  Set<String> selectedCommunities = {};

  void toggleCommunity(String community) {
    setState(() {
      if (selectedCommunities.contains(community)) {
        selectedCommunities.remove(community);
      } else {
        selectedCommunities.add(community);
      }
    });
  }

  Future<void> addDatatoMap(String email) async {
    try {
      DocumentSnapshot documentSnapshot =
          await FirebaseFirestore.instance.collection("Users").doc(email).get();
      log("sfbfsbfdbfdzbdfbdbbzdbfzdb");
      userData = documentSnapshot.data() as Map<String, dynamic>;
      log(userData["username"]);
    } catch (e) {
      log("Erroe while fetch");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Select Communities",
          style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black26,
        foregroundColor: Colors.white54,
      ),
      backgroundColor: const Color(0xFF1E1B28),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose at least 3 Communities to get started",
              style: GoogleFonts.roboto(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return categorySection(categories[index]);
                },
              ),
            ),
            if (selectedCommunities.length >= 3)
              ElevatedButton(
                onPressed: () async {
                  await addDatatoMap(widget.email);
                  FirebaseFirestore firestore = FirebaseFirestore.instance;

                  try {
                    await firestore
                        .collection('Users')
                        .doc(widget.email)
                        .update({
                      'joinedcommunity':
                          FieldValue.arrayUnion(selectedCommunities.toList()),
                    });
                    log("Values added successfully!");
                  } catch (e) {
                    log("Error updating document: $e");
                  }

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomeScreen(
                              userdata: userData,
                            )),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(
                  "Next",
                  style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget categorySection(Map<String, dynamic> category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category["categoryName"],
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: category["communities"].map<Widget>((community) {
            final isSelected = selectedCommunities.contains(community);
            return GestureDetector(
              onTap: () => toggleCommunity(community),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color.fromARGB(255, 85, 83, 99)
                      : const Color(0xFF2B2A33),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: isSelected
                        ? const Color.fromARGB(255, 79, 206, 248)
                        : Colors.white30,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  community,
                  style: GoogleFonts.roboto(
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
