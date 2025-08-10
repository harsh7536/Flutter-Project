import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trendtalks/comment_section.dart';
import 'package:trendtalks/community_page.dart';
import 'package:trendtalks/profilepage.dart';
import 'package:trendtalks/textcommentzoom.dart';

class TextContentZoom extends StatefulWidget {
  Map<String, dynamic> postdata;
  Map<String, dynamic> userdata;
  TextContentZoom({super.key, required this.postdata, required this.userdata});
  @override
  State createState() => _TextContentZoomState();
}

class _TextContentZoomState extends State<TextContentZoom> {
  List<Map<String, dynamic>> commentsdata = [];
  Future<void> _fetchexistingcomments(List<String> idlist) async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('Comments');

    for (String docId in idlist) {
      DocumentSnapshot documentSnapshot = await collection.doc(docId).get();
      if (documentSnapshot.exists) {
        // Access the document data
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        commentsdata.add(data);
        log('Document ID exists');
      } else {
        log('Document with ID $docId does not exist.');
      }
      log("${commentsdata}");
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchexistingcomments(widget.postdata["comments"].cast<String>());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Text(
          "Post",
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
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
                        height: 33,
                        width: 33,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber,
                        ),
                        child: ClipOval(
                          child: Image.network(widget.postdata["communitypic"],fit: BoxFit.fill,),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        "${widget.postdata["community"]}",
                        style: GoogleFonts.roboto(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromRGBO(124, 206, 255, 1.0),
                        ),
                      ),
                    ]),
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
                    "posted by: ${widget.postdata["username"]}",
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 13,
              ),
              Text(
                "${widget.postdata["title"]}",
                style: GoogleFonts.roboto(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color.fromARGB(255, 192, 229, 247),
                ),
              ),
              const SizedBox(
                height: 7,
              ),
              Text(
                "${widget.postdata["description"]}",
                style: GoogleFonts.roboto(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.w400),
              ),
              const SizedBox(
                height: 13,
              ),
              if (widget.postdata["pictures"] != "")
                CarouselSlider.builder(
                  itemCount: widget.postdata["pictures"].length,
                  itemBuilder: (context, imageIndex, realIndex) {
                    return ClipRRect(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.network(
                            widget.postdata["pictures"][imageIndex],
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
                                "${realIndex + 1}/${widget.postdata["pictures"].length}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  options: CarouselOptions(
                    enableInfiniteScroll: false,
                    viewportFraction: 1,
                    aspectRatio: 4 / 5,
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              if (commentsdata.isNotEmpty)
                Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white70, width: 1)),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration:
                              const BoxDecoration(color: Colors.white70),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              "Comments",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        Textcommentzoom.show(
                            context, widget.userdata, commentsdata),
                      ],
                    ) // CommentSectionPage(postdata: widget.postdata, userdata: widget.userdata)

                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mainCommentCard(Map<String, dynamic> comment, int mainIndex) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => const UserProfilePage()),
              // );
            },
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(comment['userIcon']),
                  radius: 13,
                ),
                const SizedBox(width: 12),
                Text(
                  comment['userName'],
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            comment['commentText'],
            style: GoogleFonts.roboto(color: Colors.white70),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_upward,
                    color: comment["support"] == "upvote"
                        ? const Color.fromARGB(255, 79, 206, 248)
                        : Colors.white54),
                onPressed: () {
                  if (comment["support"] == "upvote") {
                    comment["support"] = "";
                  } else {
                    comment["support"] = "upvote";
                  }
                  setState(() {});
                },
              ),
              Text(
                comment['likeCount'].toString(),
                style: const TextStyle(color: Colors.white54),
              ),
              IconButton(
                icon: Icon(Icons.arrow_downward,
                    color: comment["support"] == "downvote"
                        ? const Color.fromRGBO(255, 99, 99, 1.0)
                        : Colors.white54),
                onPressed: () {
                  if (comment["support"] == "downvote") {
                    comment["support"] = "";
                  } else {
                    comment["support"] = "downvote";
                  }
                  setState(() {});
                },
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white54),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget replyCard(List<Map<String, dynamic>> replies, int replyMainIndex) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Colors.white24)),
      ),
      child: Column(
        children:
            replies.map((reply) => replyCardUI(reply, replyMainIndex)).toList(),
      ),
    );
  }

  Widget replyCardUI(Map<String, dynamic> reply, int mainIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => const UserProfilePage()),
              // );
            },
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(reply['userIcon']),
                  radius: 13,
                ),
                const SizedBox(width: 12),
                Text(
                  reply['userName'],
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            reply['commentText'],
            style: GoogleFonts.roboto(color: Colors.white70),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_upward,
                    color: reply["support"] == "upvote"
                        ? const Color.fromARGB(255, 79, 206, 248)
                        : Colors.white54),
                onPressed: () {
                  if (reply["support"] == "upvote") {
                    reply["support"] = "";
                  } else {
                    reply["support"] = "upvote";
                  }
                  setState(() {});
                },
              ),
              Text(
                reply['likeCount'].toString(),
                style: const TextStyle(color: Colors.white54),
              ),
              IconButton(
                icon: Icon(Icons.arrow_downward,
                    color: reply["support"] == "downvote"
                        ? const Color.fromRGBO(255, 99, 99, 1.0)
                        : Colors.white54),
                onPressed: () {
                  if (reply["support"] == "downvote") {
                    reply["support"] = "";
                  } else {
                    reply["support"] = "downvote";
                  }
                  setState(() {});
                },
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white54),
                onPressed: () {},
              ),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }
}
