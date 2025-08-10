import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trendtalks/card_images_zoom.dart';
import 'package:trendtalks/comment_section.dart';
import 'package:trendtalks/explore_page.dart';
import 'package:trendtalks/text_content_zoom.dart';
import 'create_post.dart';
import 'left_drawer.dart';
import 'profile_bottom_sheet.dart';
import "package:curved_navigation_bar/curved_navigation_bar.dart";

import "search_page.dart";

class HomeScreen extends StatefulWidget {
  Map<String, dynamic> userdata;
  HomeScreen({super.key, required this.userdata});
  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // bool isbookmarked = false;
  List<String> postIdlist = [];
  List<Map<String, dynamic>> postsdata = [];
  @override
  void initState() {
    super.initState();

    _fetchFeedData(widget.userdata["joinedcommunity"].cast<String>());
    Future.delayed(const Duration(seconds: 2), _refreshData);
  }

  Future<void> _fetchFeedData(List<String> joinedcommunity) async {
    postsdata.clear();
    postIdlist.clear();

    for (int i = 0; i < joinedcommunity.length; i++) {
      log("$i");
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("Community")
          .doc(joinedcommunity[i])
          .get();
      if (documentSnapshot.exists) {
        log("exists");
        postIdlist = List<String>.from(documentSnapshot["Posts"]);
        log("$postIdlist");
      } else {
        log("Document does not exist");
      }
      try {
        List<DocumentSnapshot> documents = await Future.wait(postIdlist.map(
            (id) =>
                FirebaseFirestore.instance.collection("Posts").doc(id).get()));
        for (var document in documents) {
          if (document.exists) {
            postsdata.add(document.data() as Map<String, dynamic>);
            log("$postsdata");
          }
        }
        postsdata.sort((a, b) {
          Timestamp timestampA = a["timestamp"];
          Timestamp timestampB = b["timestamp"];

          
          DateTime dateTimeA = timestampA.toDate();
          DateTime dateTimeB = timestampB.toDate();

          return dateTimeB
              .compareTo(dateTimeA); 
        });

        setState(() {});
      } catch (e) {
        log("error");
      }
    }
  }

  int _currentIndex = 0;

  Future<void> getRefresherdData() async {
    String emailrefresh = widget.userdata["email"];
    widget.userdata.clear();
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("Users")
          .doc(emailrefresh)
          .get();
      log("sfbfsbfdbfdzbdfbdbbzdbfzdb");
      widget.userdata = documentSnapshot.data() as Map<String, dynamic>;
      log(widget.userdata["username"]);
      log("${widget.userdata}");
    } catch (e) {
      log("Erroe while fetch");
    }
    setState(() {});
  }

  Future<void> _refreshData() async {
    increamenter = 0;

    log("refreshing******");

    log("Posts clreared");
    

    await getRefresherdData();

    _fetchFeedData(widget.userdata["joinedcommunity"].cast<String>());

    log("sefreshed");

    setState(() {});
  }

  List<int> bookmarkindex = [];
  Future<void> addupvote(String docid, String value) async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('Posts');
    log("$docid");
    log(value);
    try {
      
      await collection.doc(docid).update({'support': value});
      log("String added to 'support' field successfully!");
    } catch (e) {
      log("Error adding string to 'support' field: $e");
    }
  }

  Future<void> adddownvote(String docid, String value) async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('Posts');

    try {
      
      await collection.doc(docid).update({'support': value});
      log("String added to 'support' field successfully!");
    } catch (e) {
      log("Error adding string to 'support' field: $e");
    }
  }

  Future<void> upvote(String docid, int flag) async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('Posts');
    if (flag == 0) {
      try {
        
        await collection.doc(docid).update({
          'like': FieldValue.arrayUnion([widget.userdata["email"]])
        });
        log("String added to 'support' field successfully!");
      } catch (e) {
        log("Error adding string to 'support' field: $e");
      }
    } else {
      try {
        
        await collection.doc(docid).update({
          'like': FieldValue.arrayRemove([widget.userdata["email"]])
        });
        log("String added to 'support' field successfully!");
      } catch (e) {
        log("Error adding string to 'support' field: $e");
      }
    }
  }

  Future<void> downvote(String docid, int flag) async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('Posts');
    if (flag == 0) {
      try {
        
        await collection.doc(docid).update({
          'dislike': FieldValue.arrayUnion([widget.userdata["email"]])
        });
        log("String added to 'support' field successfully!");
      } catch (e) {
        log("Error adding string to 'support' field: $e");
      }
    } else {
      try {
        
        await collection.doc(docid).update({
          'dislike': FieldValue.arrayRemove([widget.userdata["email"]])
        });
        log("String added to 'support' field successfully!");
      } catch (e) {
        log("Error adding string to 'support' field: $e");
      }
    }
  }

  int increamenter = 0;
  int likecontext = -1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 33, 38, 41),
        title: Text(
          "TrendTalks",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SearchPage(
                          emailkey: widget.userdata["email"],
                          userdata: widget.userdata,
                        )),
              );
            },
            icon: const Icon(Icons.search),
            color: const Color.fromRGBO(255, 255, 255, 1.0),
            iconSize: 30,
          ),
          GestureDetector(
            onTap: () {
              openProfileBottomSheet();
            },
            child: Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.white),
                //color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                  child: Image.network(
                widget.userdata["profilepic"] ?? "",
                fit: BoxFit.fill,
              )),
            ),
          ),
        ],
      ),
      drawer: LeftDrawer(
        usedata: widget.userdata,
      ),
      backgroundColor: const Color.fromRGBO(26, 26, 27, 1),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _currentIndex == 0 || _currentIndex == 1
            ? ListView.builder(
                itemCount: postsdata.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromRGBO(45, 63, 88, 1.0),
                          Color.fromRGBO(25, 42, 70, 1.0),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black54.withOpacity(0.5),
                            offset: const Offset(0, 3),
                            blurRadius: 5,
                            spreadRadius: -3),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) =>
                                  //           const CommunityProfilePage()),
                                  // );
                                },
                                child: Row(children: [
                                  Container(
                                    height: 30,
                                    width: 30,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.amber,
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        postsdata[index]["communitypic"],
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "${postsdata[index]["community"]}",
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color.fromRGBO(
                                          124, 206, 255, 1.0),
                                    ),
                                  ),
                                ]),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await FirebaseFirestore.instance
                                      .collection("Users")
                                      .doc(widget.userdata["email"])
                                      .update({
                                    'bookmark': FieldValue.arrayUnion(
                                        [postsdata[index]["postId"]])
                                  });
                                  bookmarkindex.add(index);

                                  setState(() {});
                                },
                                child: Icon(
                                    bookmarkindex.contains(index)
                                        ? Icons.bookmark_added
                                        : Icons.bookmark_add_outlined,
                                    color: Colors.white,
                                    size: 22),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 39.0),
                            child: GestureDetector(
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) => const UserProfilePage()),
                                // );
                              },
                              child: Text(
                                "posted by: ${postsdata[index]["username"]}",
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (postsdata[index]["title"].isNotEmpty)
                            Text(
                              "${postsdata[index]["title"]}",
                              style: GoogleFonts.roboto(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: const Color.fromARGB(255, 192, 229, 247),
                              ),
                            ),
                          if (postsdata[index]["description"].isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TextContentZoom(
                                            postdata: postsdata[index],
                                            userdata: widget.userdata,
                                          )),
                                );
                              },
                              child: Text(
                                "${postsdata[index]["description"]}",
                                style: GoogleFonts.roboto(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          const SizedBox(
                            height: 5,
                          ),
                          if (postsdata[index]["pictures"] != "")
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(10)),
                              child: CarouselSlider.builder(
                                itemCount: postsdata[index]['pictures'].length,
                                itemBuilder: (context, imageIndex, realIndex) {
                                  return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ImageZoom(
                                                    imageUrls:
                                                        List<String>.from(
                                                            postsdata[index]
                                                                ["pictures"]),
                                                  )),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Image.network(
                                                postsdata[index]['pictures']
                                                    [imageIndex],
                                                fit: BoxFit.fill,
                                              ),
                                              Positioned(
                                                right: 0,
                                                top: 0,
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  color: Colors.white12,
                                                  height: 25,
                                                  width: 35,
                                                  child: Text(
                                                    "${realIndex + 1}/${postsdata[index]['pictures'].length}",
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ),
                                              ),
                                            ]),
                                      ));
                                },
                                options: CarouselOptions(
                                  enableInfiniteScroll: false,
                                  viewportFraction: 1,
                                  aspectRatio: 4 / 5,
                                ),
                              ),
                            ),
                          const SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        if (postsdata[index]["support"] ==
                                            "upvote") {
                                          postsdata[index]["support"] = "";
                                          await addupvote(
                                              postsdata[index]["postId"], "");
                                          await upvote(
                                              postsdata[index]["postId"], 1);
                                          await downvote(
                                              postsdata[index]["postId"], 1);
                                          increamenter = 0;
                                          likecontext = index;
                                        } else {
                                          postsdata[index]["support"] =
                                              "upvote";
                                          await addupvote(
                                              postsdata[index]["postId"],
                                              "upvote");
                                          await upvote(
                                              postsdata[index]["postId"], 0);
                                          await downvote(
                                              postsdata[index]["postId"], 1);
                                          increamenter = 1;
                                          likecontext = index;
                                        }
                                        log("${postsdata[index]["like"].length - postsdata[index]["dislike"].length}");
                                        setState(() {});
                                      },
                                      child: Icon(
                                        Icons.arrow_upward,
                                        color: postsdata[index]["support"] ==
                                                "upvote"
                                            ? const Color.fromARGB(
                                                255, 79, 206, 248)
                                            : Colors.white70,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: Text(
                                        likecontext == index
                                            ? "${postsdata[index]["like"].length - postsdata[index]["dislike"].length + increamenter}"
                                            : "${postsdata[index]["like"].length - postsdata[index]["dislike"].length}",
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        if (postsdata[index]["support"] ==
                                            "downvote") {
                                          postsdata[index]["support"] = "";
                                          await adddownvote(
                                              postsdata[index]["postId"], "");
                                          await downvote(
                                              postsdata[index]["postId"], 1);
                                          await upvote(
                                              postsdata[index]["postId"], 1);
                                          increamenter = 0;
                                          likecontext = index;
                                        } else {
                                          postsdata[index]["support"] =
                                              "downvote";
                                          await adddownvote(
                                              postsdata[index]["postId"],
                                              "downvote");
                                          await downvote(
                                              postsdata[index]["postId"], 0);
                                          await upvote(
                                              postsdata[index]["postId"], 1);
                                          increamenter = -1;
                                          likecontext = index;
                                        }
                                        log("${postsdata[index]["like"].length - postsdata[index]["dislike"].length}");
                                        setState(() {});
                                      },
                                      child: Icon(
                                        Icons.arrow_downward,
                                        color: postsdata[index]["support"] ==
                                                "downvote"
                                            ? const Color.fromRGBO(
                                                255, 99, 99, 1.0)
                                            : Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CommentSectionPage(
                                                postdata: postsdata[index],
                                                userdata: widget.userdata,
                                              )),
                                    );
                                  },
                                  child: const Row(
                                    children: [
                                      const Icon(Icons.comment,
                                          color: Colors.white70),
                                      const SizedBox(width: 5),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                })
            : ExplorePage(
                userdata: widget.userdata,
              ),
      ),
      bottomNavigationBar: Stack(alignment: Alignment.bottomCenter, children: [
        CurvedNavigationBar(
          backgroundColor: Colors.redAccent,
          animationDuration: const Duration(milliseconds: 300),
          color: Color.fromARGB(255, 69, 76, 83),
          index: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            Icon(Icons.home, color: Colors.white),
            const SizedBox(
              width: 10,
            ),
            Icon(Icons.explore, color: Colors.white),
          ],
        ),
        Positioned(
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreatePostPage(
                          userdata: widget.userdata,
                        )),
              );
            },
            child: Container(
              alignment: Alignment.center,
              height: 80,
              width: 140,
              color: Color.fromARGB(255, 69, 76, 83),
              child: const Icon(Icons.create, size: 27, color: Colors.white),
            ),
          ),
        ),
      ]),
    );
  }

  void openProfileBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ProfileBottomSheet(
          userdata: widget.userdata,
        );
      },
    );
  }
}
