import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trendtalks/create_community.dart';

import 'community_page.dart';
import 'profilepage.dart';

class LeftDrawer extends StatefulWidget {
  Map<String, dynamic> usedata;
  LeftDrawer({super.key, required this.usedata});
  @override
  State createState() => _LeftDrawerState();
}

List<Map<String, dynamic>> followerdatalist = [];
List<Map<String, dynamic>> communitydatalist = [];

class _LeftDrawerState extends State<LeftDrawer> {
  @override
  void initState() {
    super.initState();
    communitydatalist.clear();
    followerdatalist.clear();
    for (int i = 0; i < widget.usedata["following"].length; i++) {
      addData(i, 2);
    }
    for (int i = 0; i < widget.usedata["joinedcommunity"].length; i++) {
      addData(i, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 53, 65, 91),
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              colors: [
                Color.fromRGBO(40, 53, 79, 1.0),
                Color.fromRGBO(87, 196, 229, 1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TrendTalks',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: const Color.fromRGBO(255, 255, 255, 1.0),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Hello,',
                  style: GoogleFonts.tangerine(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.usedata["username"],
                      style: GoogleFonts.tangerine(
                          color: Colors.white,
                          fontSize: 35,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ExpansionTile(
            onExpansionChanged: (flag) {
              setState(() {});
            },
            leading: const Icon(Icons.group,
                color: Color.fromRGBO(255, 255, 255, 1.0)),
            title: Text(
              "Your Community",
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w500,
                color: const Color.fromRGBO(255, 255, 255, 1.0),
                fontSize: 16,
              ),
            ),
            iconColor: const Color.fromRGBO(255, 255, 255, 1.0),
            collapsedIconColor: const Color.fromRGBO(200, 200, 200, 1.0),
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateCommunityPage(
                                  userdata: widget.usedata,
                                )),
                      );
                    },
                    child: SizedBox(
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 15,
                          ),
                          const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Create a community",
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w500,
                              color: const Color.fromRGBO(255, 255, 255, 1.0),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: widget.usedata["joinedcommunity"].length,
                    itemBuilder: (context, index) {
                      return comunityLabel(index);
                    },
                  )
                ],
              ),
            ],
          ),
          ExpansionTile(
            onExpansionChanged: (flag) {
              setState(() {});
            },
            leading: const Icon(Icons.person,
                color: Color.fromRGBO(255, 255, 255, 1.0)),
            title: Text(
              "Following",
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w500,
                color: const Color.fromRGBO(255, 255, 255, 1.0),
                fontSize: 16,
              ),
            ),
            iconColor: const Color.fromRGBO(255, 255, 255, 1.0),
            collapsedIconColor: const Color.fromRGBO(200, 200, 200, 1.0),
            children: [
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.usedata["following"].length,
                  itemBuilder: (context, index) {
                    return followersLabel(index);
                  })
            ],
          ),
        ],
      ),
    );
  }

  dynamic comunityLabel(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CommunityProfilePage(
                          selectedcommunity: communitydatalist[index],
                          emailkey: widget.usedata["email"],
                          isjoined: true,
                          userdata: widget.usedata,
                        )),
              );
            },
            child: Row(children: [
              Container(
                height: 25,
                width: 25,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber,
                ),
                child: ClipOval(
                  child: Image.network(
                    communitydatalist[index]["profilepic"],
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                communitydatalist[index]["name"],
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(255, 255, 255, 1.0),
                  fontSize: 15,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  dynamic followersLabel(int index) {
    // addData(index);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserProfilePage(
                      userdata: followerdatalist[index],
                      isMyprofile: false,
                      emailkey: widget.usedata["email"],
                    )),
          );
        },
        child: Row(
          children: [
            Container(
              height: 25,
              width: 25,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber,
              ),
              child: ClipOval(
                child: Image.network(
                  followerdatalist[index]["profilepic"],
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Text(
              followerdatalist[index]["username"],
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w500,
                color: const Color.fromRGBO(255, 255, 255, 1.0),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addData(int index, int flag) async {
    if (flag == 2) {
      Map<String, dynamic> followerdata;
      try {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("Users")
            .doc(widget.usedata["following"][index])
            .get();
        // log("sfbfsbfdbfdzbdfbdbbzdbfzdb");
        //log("___________________________________________________$documentSnapshot ________________________");
        followerdata = documentSnapshot.data() as Map<String, dynamic>;
        //log("Core2web********$followerdata");
        followerdatalist.add(followerdata);
        log("Incubators*********$followerdatalist");
      } catch (e) {
        log("Erroe while fetch");
      }
    } else if (flag == 1) {
      Map<String, dynamic> communitydata;
      try {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("Community")
            .doc(widget.usedata["joinedcommunity"][index])
            .get();
        // log("sfbfsbfdbfdzbdfbdbbzdbfzdb");
        //log("___________________________________________________$documentSnapshot ________________________");
        communitydata = documentSnapshot.data() as Map<String, dynamic>;
        //log("Core2web********$followerdata");
        communitydatalist.add(communitydata);
        log("Incubators*********$communitydatalist");
      } catch (e) {
        log("Erroe while fetching community");
      }
    }
  }
}
