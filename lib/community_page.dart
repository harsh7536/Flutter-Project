import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'card_ui.dart';

class CommunityProfilePage extends StatefulWidget {
  Map<String, dynamic> selectedcommunity;
  bool isjoined;
  String emailkey;
  Map<String, dynamic> userdata;
  CommunityProfilePage(
      {super.key,
      required this.selectedcommunity,
      required this.isjoined,
      required this.emailkey,
      required this.userdata});

  @override
  State createState() => _CommunityProfilePageState();
}

class _CommunityProfilePageState extends State<CommunityProfilePage> {
  int _selectedIndex = 0;
  bool isJoined = false;
  bool checkJoined() {
    log("{$widget.selectedcommunity}");
    bool isjoined;
    if (widget.selectedcommunity["members"].contains(widget.emailkey)) {
      isjoined = true;
      log("true*******************************************");
      return isjoined;
    } else {
      isjoined = false;
      log("false*******************************************");
      return isjoined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Community",
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        foregroundColor: Colors.white54,
        backgroundColor: Color.fromARGB(255, 28, 22, 22),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF2D2D2D),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF800000), Colors.black],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(
                        widget.selectedcommunity["profilepic"],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.selectedcommunity["name"],
                          style: GoogleFonts.roboto(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "members: ${widget.selectedcommunity["members"].length}",
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Positioned custom-styled Join button at top-right corner
              Positioned(
                bottom: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () async {
                    if (checkJoined() == false) {
                      await FirebaseFirestore.instance
                          .collection('Community')
                          .doc(widget.selectedcommunity["name"])
                          .update({
                        'members': FieldValue.arrayUnion([widget.emailkey])
                      });
                      widget.selectedcommunity["members"].add(widget.emailkey);
                      await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(widget.emailkey)
                          .update({
                        'joinedcommunity': FieldValue.arrayUnion(
                            [widget.selectedcommunity["name"]])
                      });
                    } else {
                      await FirebaseFirestore.instance
                          .collection('Community')
                          .doc(widget.selectedcommunity["name"])
                          .update({
                        'members': FieldValue.arrayRemove([widget.emailkey])
                      });
                      widget.selectedcommunity["members"]
                          .remove(widget.emailkey);
                      await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(widget.emailkey)
                          .update({
                        'joinedcommunity': FieldValue.arrayRemove(
                            [widget.selectedcommunity["name"]])
                      });
                    }
                    setState(() {});
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: checkJoined()
                          ? LinearGradient(
                              colors: [
                                Colors.grey.shade600,
                                Colors.grey.shade400
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [
                                Color(0xFFB04A00),
                                Color(0xFFFF7300),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(2, 4),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      checkJoined() ? "Joined" : "Join",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Tabs for Posts and About
          Container(
            color: const Color(0xFF800000),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabButton("Posts", 0),
                _buildTabButton("About", 1),
              ],
            ),
          ),

          // Content based on the selected tab
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    return GestureDetector(
      onTap: () async {
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
              fontWeight: checkJoined() ? FontWeight.bold : FontWeight.w400,
              color: checkJoined() ? Colors.white : Colors.grey[400],
            ),
          ),
          if (_selectedIndex == index)
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 3,
              width: 60,
              color: const Color(0xFFB04A00),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return CardUI(
          communitykey: widget.selectedcommunity["name"],
          selectedpage: 0,
          emailkey: widget.emailkey,
          userdata: widget.userdata,
        );
      case 1:
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
                    width: 24,
                  ),
                  Expanded(
                    child: Text(
                      widget.selectedcommunity["description"],
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
                    "rules :",
                    style: GoogleFonts.roboto(
                        color: Colors.white70,
                        fontSize: 19,
                        fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    width: 28,
                  ),
                  Expanded(
                    child: Text(
                      widget.selectedcommunity["rules"],
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
                    "created by :",
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
                      widget.selectedcommunity["createdby"].toString(),
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
                    "created on :",
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
                      "${widget.selectedcommunity["timestamp"].toDate().day}-${widget.selectedcommunity["timestamp"].toDate().month}-${widget.selectedcommunity["timestamp"].toDate().year}",
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
