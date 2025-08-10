import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trendtalks/profilepage.dart';

class CommentSectionPage extends StatefulWidget {
  Map<String, dynamic> postdata;
  Map<String, dynamic> userdata;
  CommentSectionPage(
      {super.key, required this.postdata, required this.userdata});

  @override
  State createState() => _CommentSectionPageState();
}

class _CommentSectionPageState extends State<CommentSectionPage> {
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
    Future.delayed(const Duration(seconds: 4), _refreshdata);
  }

  String checkreply = "";
  Future<void> _refreshdata() async {
    log("refreshing");

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshdata,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            "Comments",
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color.fromRGBO(70, 50, 100, 1.0),
        ),
        backgroundColor: const Color(0xFF1E1B28),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 160,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: commentsdata.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B2A33),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          mainCommentCard(commentsdata[index], index),
                          if (commentsdata[index]["replies"].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 25.0),
                              child: replyCard(
                                  commentsdata[index]["replies"], index),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            GestureDetector(
              onTap: () {
                showReplyDialog(true);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9.0),
                child: Container(
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width - 10,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 85, 83, 99),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "Add Comment ....",
                      style: TextStyle(color: Colors.white, fontSize: 15),
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
                  backgroundImage: NetworkImage(comment['profilepic']),
                  radius: 13,
                ),
                const SizedBox(width: 12),
                Text(
                  comment['username'],
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
            comment['commentdata'],
            style: GoogleFonts.roboto(color: Colors.white70),
          ),
          Row(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: () {
                  showReplyDialog(false, commentIndex: mainIndex);
                },
                child: Row(
                  children: [
                    const Icon(Icons.reply, color: Colors.white54),
                    Text(
                      "Reply",
                      style: GoogleFonts.roboto(
                          color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget replyCard(List replies, int replyMainIndex) {
    log("*************************************************${replies}***********************************************************************************************************");
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

  void showReplyDialog(bool isComment, {int? commentIndex}) {
    TextEditingController replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2B2A33),
          title: Text(
            isComment ? "Add Comment" : "Add Reply",
            style: GoogleFonts.roboto(color: Colors.white),
          ),
          content: TextField(
            controller: replyController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText:
                  isComment ? "Write your comment..." : "Write your reply...",
              hintStyle: const TextStyle(color: Colors.white60),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel",
                  style: GoogleFonts.roboto(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () async {
                if (replyController.text.isNotEmpty) {
                  if (isComment) {
                    Map<String, dynamic> data = {
                      "username": widget.userdata["username"],
                      "email": widget.userdata["email"],
                      "commentdata": replyController.text.trim(),
                      "profilepic": widget.userdata["profilepic"],
                      "timestamp": FieldValue.serverTimestamp(),
                      "community": widget.postdata["community"],
                      "replies": [],
                      "postdata": widget.postdata
                    };
                    DocumentReference commentref = await FirebaseFirestore
                        .instance
                        .collection("Comments")
                        .add(data);

                    String commentid = commentref.id;
                    log(commentid);
                    await FirebaseFirestore.instance
                        .collection("Comments")
                        .doc(commentid)
                        .update({
                      "commentid":
                          commentid, 
                    });
                    data.addAll({"commentid": commentid});
                    await FirebaseFirestore.instance
                        .collection("Users")
                        .doc(widget.userdata["email"])
                        .update({
                      "myComments": FieldValue.arrayUnion([commentid])
                    });

                    await FirebaseFirestore.instance
                        .collection("Posts")
                        .doc(widget.postdata["postId"])
                        .update({
                      "comments": FieldValue.arrayUnion([commentid])
                    });
                    commentsdata.add(data);
                    log("${commentsdata}");
                  } else {
                    log("reply is going on");
                    Map<String, dynamic> data = {
                      "username": widget.userdata["username"],
                      "email": widget.userdata["email"],
                      "replydata": replyController.text.trim(),
                      "profilepic": widget.userdata["profilepic"],
                      //"timestamp" : FieldValue.serverTimestamp(),
                      "community": widget.postdata["community"],
                      "commentid": commentsdata[commentIndex!]["commentid"]
                    };
                    log("$data");
                    log(commentsdata[commentIndex]["commentid"]);
                    await FirebaseFirestore.instance
                        .collection("Comments")
                        .doc(commentsdata[commentIndex]["commentid"])
                        .update({
                      'replies': FieldValue.arrayUnion([data]),
                    });
                    log("data added to comment");
                    commentsdata[commentIndex]["replies"].add(data);
                    log("data added to local list   cs d d d  dd  d d ");
                    log("${commentsdata[commentIndex]["replies"].add(data)}");
                  }
                  Navigator.pop(context);

                  setState(() {});
                }
              },
              child: Text(isComment ? "Comment" : "Reply",
                  style: GoogleFonts.roboto(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }

  Widget replyCardUI(Map<String, dynamic> reply, int mainIndex) {
    log("$reply");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Container(
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white12))),
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
                    backgroundImage: NetworkImage(reply["profilepic"]),
                    radius: 13,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    reply['username'],
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
              reply['replydata'],
              style: GoogleFonts.roboto(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
