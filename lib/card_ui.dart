import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:trendtalks/comment_section.dart';
import 'package:trendtalks/community_page.dart';
import 'package:trendtalks/profilepage.dart';
import 'package:trendtalks/text_content_zoom.dart';
import 'card_images_zoom.dart';

class CardUI extends StatefulWidget {
  String communitykey;
  int selectedpage;
  String emailkey;
  Map<String, dynamic> userdata;
  CardUI(
      {super.key,
      required this.communitykey,
      required this.selectedpage,
      required this.emailkey,
      required this.userdata});
  @override
  State createState() => _CardUIState();
}

class _CardUIState extends State<CardUI> {
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
          'like': FieldValue.arrayUnion([widget.emailkey])
        });
        log("String added to 'support' field successfully!");
      } catch (e) {
        log("Error adding string to 'support' field: $e");
      }
    } else {
      try {
        
        await collection.doc(docid).update({
          'like': FieldValue.arrayRemove([widget.emailkey])
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
          'dislike': FieldValue.arrayUnion([widget.emailkey])
        });
        log("String added to 'support' field successfully!");
      } catch (e) {
        log("Error adding string to 'support' field: $e");
      }
    } else {
      try {
        
        await collection.doc(docid).update({
          'dislike': FieldValue.arrayRemove([widget.emailkey])
        });
        log("String added to 'support' field successfully!");
      } catch (e) {
        log("Error adding string to 'support' field: $e");
      }
    }
  }

  List<String> postIdlist = [];
  List<Map<String, dynamic>> postsdata = [];
  @override
  void initState() {
    super.initState();
    if (widget.selectedpage == 0) {
      _fetchCommunityData();
    } else if (widget.selectedpage == 1) {
      _fetchfeed();
    }
  }

  Future<void> _fetchCommunityData() async {
    DocumentSnapshot document = await FirebaseFirestore.instance
        .collection("Community")
        .doc(widget.communitykey)
        .get();
    if (document.exists) {
      
      postIdlist = List<String>.from(document["Posts"]);

      
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
      log("$postsdata");
      log("${postsdata.length}");
    } catch (e) {
      log("error");
    }
  }

  List<String> joinedCommunity = [];

  Future<void> _fetchfeed() async {
    DocumentSnapshot document = await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget
            .communitykey) 
        .get();

    if (document.exists) {
      
      joinedCommunity = List<String>.from(document['joinedcommunity']);
      log('joined List: $joinedCommunity'); 
    } else {
      log('Document does not exist');
    }
    for (int i = 0; i < joinedCommunity.length; i++) {
      log("$i");
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("Community")
          .doc(joinedCommunity[i])
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
      } catch (e) {
        log("error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: postsdata.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                              color: const Color.fromRGBO(124, 206, 255, 1.0),
                            ),
                          ),
                        ]),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await FirebaseFirestore.instance
                              .collection("Users")
                              .doc(widget.emailkey)
                              .update({
                            'bookmark': FieldValue.arrayUnion(
                                [postsdata[index]["postId"]])
                          });
                          bookmarkindex.add(index);

                          setState(() {});
                        },
                        child: Icon(
                            bookmarkindex.contains(index)
                                ? Icons.bookmark
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
                                            imageUrls: List<String>.from(
                                                postsdata[index]["pictures"]),
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
                                        fit: BoxFit.contain,
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
                                                fontWeight: FontWeight.w700),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (postsdata[index]["support"] == "upvote") {
                                  postsdata[index]["support"] = "";
                                  await addupvote(
                                      postsdata[index]["postId"], "");
                                  await upvote(postsdata[index]["postId"], 1);
                                  await downvote(postsdata[index]["postId"], 1);
                                } else {
                                  postsdata[index]["support"] = "upvote";
                                  await addupvote(
                                      postsdata[index]["postId"], "upvote");
                                  await upvote(postsdata[index]["postId"], 0);
                                  await downvote(postsdata[index]["postId"], 1);
                                }
                                log("${postsdata[index]["like"].length - postsdata[index]["dislike"].length}");
                                setState(() {});
                              },
                              child: Icon(
                                Icons.arrow_upward,
                                color: postsdata[index]["support"] == "upvote"
                                    ? const Color.fromARGB(255, 79, 206, 248)
                                    : Colors.white70,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                "${postsdata[index]["like"].length - postsdata[index]["dislike"].length}",
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (postsdata[index]["support"] == "downvote") {
                                  postsdata[index]["support"] = "";
                                  await adddownvote(
                                      postsdata[index]["postId"], "");
                                  await downvote(postsdata[index]["postId"], 1);
                                  await upvote(postsdata[index]["postId"], 1);
                                } else {
                                  postsdata[index]["support"] = "downvote";
                                  await adddownvote(
                                      postsdata[index]["postId"], "downvote");
                                  await downvote(postsdata[index]["postId"], 0);
                                  await upvote(postsdata[index]["postId"], 1);
                                }
                                log("${postsdata[index]["like"].length - postsdata[index]["dislike"].length}");
                                setState(() {});
                              },
                              child: Icon(
                                Icons.arrow_downward,
                                color: postsdata[index]["support"] == "downvote"
                                    ? const Color.fromRGBO(255, 99, 99, 1.0)
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
                                  builder: (context) => CommentSectionPage(
                                        postdata: postsdata[index],
                                        userdata: widget.userdata,
                                      )),
                            );
                          },
                          child: const Row(
                            children: [
                              const Icon(Icons.comment, color: Colors.white70),
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
        });
  }
}
