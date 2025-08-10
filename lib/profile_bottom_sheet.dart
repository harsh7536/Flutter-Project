import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trendtalks/saved_posts.dart';
import 'package:trendtalks/signup.dart';
import "profilepage.dart";

class ProfileBottomSheet extends StatefulWidget {
  Map<String, dynamic> userdata;
  ProfileBottomSheet({super.key, required this.userdata});
  @override
  State createState() => _ProfileBottomSheetState();
}

class _ProfileBottomSheetState extends State<ProfileBottomSheet> {
  @override
  Widget build(BuildContext conetx) {
    return Container(
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
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: Text(
                'Visit Profile',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(255, 255, 255, 1.0),
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserProfilePage(
                            userdata: widget.userdata,
                            isMyprofile: true,
                            emailkey: widget.userdata["email"],
                          )),
                );
              }),
          ListTile(
              leading: const Icon(Icons.bookmark, color: Colors.white),
              title: Text(
                'Saved Posts',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(255, 255, 255, 1.0),
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SavedPosts(
                            emailkey: widget.userdata["email"],
                            userdata: widget.userdata,
                          )),
                );
              }),
          ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: Text(
                'LogOut',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(255, 255, 255, 1.0),
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupPage()),
                    (Route<dynamic> route) => false);
              }),
        ],
      ),
    );
  }
}
