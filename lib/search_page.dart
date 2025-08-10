import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trendtalks/community_page.dart';

import 'profilepage.dart';

class SearchPage extends StatefulWidget {
  Map<String, dynamic> userdata;
  String emailkey;
  SearchPage({super.key, required this.emailkey, required this.userdata});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int selectedIndex = 0;
  String searchdata = "";
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> community = [];

  Future<void> getsearchuserdata(String searchedText) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('username', isEqualTo: searchedText)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      List<DocumentSnapshot> documentSnapshot = querySnapshot.docs;
      
      for (var document in documentSnapshot) {
        users.add({
          "email": document.get("email"),
          "username": document.get("username"),
          "profilepic": document.get("profilepic"),
          "about": document.get("about"),
          "timestamp": document.get("timestamp"),
          "followers": document.get("followers"),
          "following": document.get("following"),
          "myComments": document.get("myComments")
        });
        log(document.get("email"));
        log(document.get("username"));
        log("$users");
      }
    } else {
      log("No document found with the specified username.");
      users.clear();
    }
  }

  Future<void> getsearchcommunitydata(String searchedText) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('Community')
        .doc(searchedText)
        .get();

    if (docSnapshot.exists) {
      community.add({
        "name": docSnapshot.get("name"),
        "description": docSnapshot.get("description"),
        "profilepic": docSnapshot.get("profilepic"),
        "rules": docSnapshot.get("rules"),
        "timestamp": docSnapshot.get("timestamp"),
        "createdby": docSnapshot.get("createdby"),
        "members": docSnapshot.get("members")
      });
      log("${docSnapshot.get("name")}");
      log("$community");
    } else {
      log("No document found of community.");
      community.clear();
    }
  }

  int selectedoption = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title:
            Text('Search', style: GoogleFonts.montserrat(color: Colors.white)),
        backgroundColor: const Color.fromRGBO(40, 53, 79, 1.0),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(40, 53, 79, 1.0),
              Color.fromRGBO(87, 196, 229, 1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                onChanged: (searched) {
                  getsearchuserdata(searched);
                  getsearchcommunitydata(searched);
                  setState(() {});
                },
                style: GoogleFonts.roboto(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: GoogleFonts.roboto(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  options('Users', 0),
                  const SizedBox(width: 20),
                  options('Communities', 1),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: selectedIndex == 0
                    ? _buildUserResults()
                    : _buildCommunityResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget options(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: selectedIndex == index ? Colors.white12 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: GoogleFonts.roboto(
            color: selectedIndex == index ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildUserResults() {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserProfilePage(
                          userdata: users[index],
                          isMyprofile: false,
                          emailkey: widget.emailkey,
                        )),
              );
            },
            child: Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber,
                  ),
                  child: ClipOval(
                    child: Image.network(
                      users[index]["profilepic"],
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  users.isNotEmpty ? users[index]["username"] : "usernotfound",
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    color: const Color.fromRGBO(255, 255, 255, 1.0),
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommunityResults() {
    return ListView.builder(
      itemCount: community.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CommunityProfilePage(
                          selectedcommunity: community[index],
                          isjoined: false,
                          emailkey: widget.emailkey,
                          userdata: widget.userdata,
                        )),
              );
            },
            child: Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber,
                  ),
                  child: ClipOval(
                    child: Image.network(
                      community[index]["profilepic"],
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  community.isNotEmpty
                      ? community[index]["name"]
                      : "communitynotfound",
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    color: const Color.fromRGBO(255, 255, 255, 1.0),
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
