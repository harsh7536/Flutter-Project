import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Textcommentzoom {
  static Widget show(BuildContext context, Map<String, dynamic> user0data,
      List<Map<String, dynamic>> post0data) {
    Textcommentzoom obj = Textcommentzoom();
    log("${user0data}");
    log("${post0data}");
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: post0data.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B2A33),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      obj.mainCommentCard(post0data[index], index),
                      if (post0data[index]["replies"].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child:
                              obj.replyCard(post0data[index]["replies"], index),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
                  //showReplyDialog(false, commentIndex: mainIndex);
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
