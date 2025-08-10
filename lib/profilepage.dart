import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trendtalks/card_images_zoom.dart';
import 'package:trendtalks/comment_section.dart';
import 'package:trendtalks/text_content_zoom.dart';
import 'card_ui.dart';

class UserProfilePage extends StatefulWidget {
  Map<String, dynamic> userdata;
  bool isMyprofile;
  String emailkey;
  UserProfilePage(
      {super.key,
      required this.userdata,
      required this.isMyprofile,
      required this.emailkey});

  @override
  State createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  void initState() {
    super.initState();
    getidlist();
    log("${widget.userdata}");
    if (widget.userdata["myComments"] != null) {
      getcommetsdatalist(widget.userdata["myComments"].cast<String>());
    }
    log("chalu ahe re..................");
  }

  List<Map<String, dynamic>> commentsdata = [];
  List<String> mypostid = [];
  List<Map<String, dynamic>> postsdata = [];

  Future<void> getcommetsdatalist(List<String> cidlist) async {
    log("$cidlist");
    try {
      List<DocumentSnapshot> documents = await Future.wait(cidlist.map((id) =>
          FirebaseFirestore.instance.collection("Comments").doc(id).get()));
      for (var document in documents) {
        if (document.exists) {
          commentsdata.add(document.data() as Map<String, dynamic>);
          // log("copostsdata");
        }
      }

      log("$commentsdata");
      //log("After Sortin *********************************************************");

      setState(() {});
    } catch (e) {
      log("error ahe reeeeeeee");
    }
  }

  Future<void> getidlist() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.userdata["email"])
        .get();

    if (documentSnapshot.exists) {
      mypostid = List<String>.from(documentSnapshot.get("Myposts"));
    }

    try {
      List<DocumentSnapshot> documents = await Future.wait(mypostid.map((id) =>
          FirebaseFirestore.instance.collection("Posts").doc(id).get()));
      for (var document in documents) {
        if (document.exists) {
          postsdata.add(document.data() as Map<String, dynamic>);
          //log("$postsdata");
        }
      }
      // log("Before Sortin *********************************************************");
      //log("$postsdata");
      postsdata.sort((a, b) {
        Timestamp timestampA = a["timestamp"];
        Timestamp timestampB = b["timestamp"];

        
        DateTime dateTimeA = timestampA.toDate();
        DateTime dateTimeB = timestampB.toDate();

        return dateTimeB
            .compareTo(dateTimeA); 
      });
      //log("$postsdata");
      //log("After Sortin *********************************************************");

      setState(() {});
    } catch (e) {
      log("error ahe reeeeeeee");
    }
  }

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

  int _selectedIndex = 0;

  bool checkFollowing() {
    bool isfollowing;
    if (widget.userdata["followers"].contains(widget.emailkey)) {
      isfollowing = true;
      return isfollowing;
    } else {
      isfollowing = false;
      return isfollowing;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isMyprofile ? "My Profile" : "Profile",
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(40, 53, 79, 1.0),
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 53, 65, 91),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          NetworkImage(widget.userdata["profilepic"]),
                          
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userdata["username"],
                          style: GoogleFonts.roboto(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "followers: ${widget.userdata["followers"].length}",
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 60,
                            ),
                            if (widget.isMyprofile == false)
                              ElevatedButton(
                                  onPressed: () async {
                                    if (checkFollowing() == false) {
                                      await FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(widget.userdata["email"])
                                          .update({
                                        'followers': FieldValue.arrayUnion(
                                            [widget.emailkey])
                                      });
                                      widget.userdata["followers"]
                                          .add(widget.emailkey);
                                      await FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(widget.emailkey)
                                          .update({
                                        'following': FieldValue.arrayUnion(
                                            [widget.userdata["email"]])
                                      });
                                    } else {
                                      await FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(widget.userdata["email"])
                                          .update({
                                        'followers': FieldValue.arrayRemove(
                                            [widget.emailkey])
                                      });
                                      widget.userdata["followers"]
                                          .remove(widget.emailkey);
                                      await FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(widget.emailkey)
                                          .update({
                                        'following': FieldValue.arrayRemove(
                                            [widget.userdata["email"]])
                                      });
                                    }
                                    setState(() {});
                                  },
                                  style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                          checkFollowing()
                                              ? Color.fromARGB(
                                                  255, 48, 114, 229)
                                              : Colors.white70)),
                                  child: checkFollowing()
                                      ? const Text(
                                          "Following",
                                          style: TextStyle(color: Colors.white),
                                        )
                                      : const Text(
                                          "Follow",
                                        ))
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: const Color.fromRGBO(40, 53, 79, 1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabButton("Posts", 0),
                _buildTabButton("Comments", 1),
                _buildTabButton("About", 2),
              ],
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight:
                  _selectedIndex == index ? FontWeight.bold : FontWeight.w400,
              color: _selectedIndex == index ? Colors.white : Colors.grey[400],
            ),
          ),
          if (_selectedIndex == index)
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 3,
              width: 60,
              color: Colors.blueAccent,
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return ListView.builder(
            itemCount: postsdata.length,
            itemBuilder: (context, index) {
              return Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                                  color:
                                      const Color.fromRGBO(124, 206, 255, 1.0),
                                ),
                              ),
                            ]),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {});
                            },
                            child: const Icon(Icons.bookmark_add_outlined,
                                color: Colors.white, size: 22),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 39.0),
                        child: GestureDetector(
                          onTap: () {},
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
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                                      // increamenter = -1;
                                    } else {
                                      postsdata[index]["support"] = "upvote";
                                      await addupvote(
                                          postsdata[index]["postId"], "upvote");
                                      await upvote(
                                          postsdata[index]["postId"], 0);
                                      await downvote(
                                          postsdata[index]["postId"], 1);
                                      // increamenter = 1;
                                    }
                                    log("${postsdata[index]["like"].length - postsdata[index]["dislike"].length}");
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.arrow_upward,
                                    color:
                                        postsdata[index]["support"] == "upvote"
                                            ? const Color.fromARGB(
                                                255, 79, 206, 248)
                                            : Colors.white70,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
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
                                    if (postsdata[index]["support"] ==
                                        "downvote") {
                                      postsdata[index]["support"] = "";
                                      await adddownvote(
                                          postsdata[index]["postId"], "");
                                      await downvote(
                                          postsdata[index]["postId"], 1);
                                      await upvote(
                                          postsdata[index]["postId"], 1);
                                      // increamenter = 1;
                                    } else {
                                      postsdata[index]["support"] = "downvote";
                                      await adddownvote(
                                          postsdata[index]["postId"],
                                          "downvote");
                                      await downvote(
                                          postsdata[index]["postId"], 0);
                                      await upvote(
                                          postsdata[index]["postId"], 1);
                                      // increamenter = -1;
                                    }
                                    log("${postsdata[index]["like"].length - postsdata[index]["dislike"].length}");
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.arrow_downward,
                                    color: postsdata[index]["support"] ==
                                            "downvote"
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
                              child: Row(
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
            }); //const CardUI();
      case 1:
        return ListView.builder(
            shrinkWrap: true,
            itemCount: commentsdata.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TextContentZoom(
                                postdata: commentsdata[index]["postdata"],
                                userdata: widget.userdata)));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            commentsdata[index]["postdata"]["title"] as String,
                            style: GoogleFonts.roboto(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: const Color.fromARGB(255, 192, 229, 247),
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            commentsdata[index]["commentdata"],
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            });

      case 2:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "about :",
                    style: GoogleFonts.roboto(
                        color: Colors.white70,
                        fontSize: 19,
                        fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  Expanded(
                    child: Text(
                      widget.userdata["about"],
                      style: GoogleFonts.roboto(
                          color: Colors.white70, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "email :",
                    style: GoogleFonts.roboto(
                        color: Colors.white70,
                        fontSize: 19,
                        fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  Expanded(
                    child: Text(
                      widget.userdata["email"],
                      style: GoogleFonts.roboto(
                          color: Colors.white70, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "joined :",
                    style: GoogleFonts.roboto(
                        color: Colors.white70,
                        fontSize: 19,
                        fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Text(
                      "${widget.userdata["timestamp"].toDate().day}-${widget.userdata["timestamp"].toDate().month}-${widget.userdata["timestamp"].toDate().year}",
                      style: GoogleFonts.roboto(
                          color: Colors.white70, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Text(
          //   "About user and info will be displayed here",
          //  style: GoogleFonts.roboto(color: Colors.white70, fontSize: 16),
          //  textAlign: TextAlign.center,
          // ),
        );
      default:
        return Container();
    }
  }
}
