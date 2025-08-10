import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:trendtalks/community_page.dart';

class ExplorePage extends StatefulWidget {
  Map<String, dynamic> userdata;
  ExplorePage({super.key, required this.userdata});

  @override
  State createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  void initState() {
    super.initState();
    log("$allcommunity");
    getCommunityDocuments();
    fetchMatchingDocs(docid);
    log("$allcommunity");
  }

  // final List<String> categories = [
  //   'Entertainment', 'Sports', 'Tech'
  // ];
  List<Map<String, dynamic>> allcommunity = [];
  List<String> docid = ["cricket", "movies", "tennis"];
  List<Map<String, dynamic>> carouseldata = [];

  Future<void> fetchMatchingDocs(List<String> docIds) async {
    List<Map<String, dynamic>> result = [];
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    for (String docId in docIds) {
      try {
        DocumentSnapshot<Map<String, dynamic>> docSnapshot =
            await firestore.collection('Community').doc(docId).get();

        if (docSnapshot.exists) {
          
          carouseldata.add(docSnapshot.data()!);
        }
      } catch (e) {
        log("Error fetching document with ID $docId: $e");
      }
    }
    log("$carouseldata");
    setState(() {});
  }

  Future<void> getCommunityDocuments() async {
    
    CollectionReference communityCollection =
        FirebaseFirestore.instance.collection('Community');

    
    QuerySnapshot querySnapshot = await communityCollection.get();

    

    for (var doc in querySnapshot.docs) {
      
      allcommunity.add(doc.data() as Map<String, dynamic>);
    }
    setState(() {});
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white24,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel Slider
            Container(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 250,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  autoPlayInterval: const Duration(seconds: 4),
                ),
                items: carouseldata.map((community) {
                  return Builder(
                    builder: (BuildContext context) {
                      return GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //           context,
                          //           MaterialPageRoute(
                          //             builder: (context) =>  CommunityProfilePage(selectedcommunity: carouseldata[],),
                          //           ),
                          //         );
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              community['profilepic']!,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              child: Text(
                                community['name']!,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10.0,
                                      color: Colors.black.withOpacity(0.7),
                                      offset: const Offset(2.0, 2.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Communities",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Wrap(
                spacing: 8.0, // Horizontal space between items
                runSpacing: 8.0, // Vertical space between items
                children: List.generate(
                  allcommunity.length,
                  (index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CommunityProfilePage(
                                  selectedcommunity: allcommunity[index],
                                  isjoined: false,
                                  emailkey: widget.userdata["email"],
                                  userdata: widget.userdata)),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.only(top: 7),
                        width: 120,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.white.withOpacity(0.6)),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                  allcommunity[index]['profilepic']!),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              allcommunity[index]['name'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Categories and Community Cards
            // Container(
            //   child: ListView.builder(
            //     shrinkWrap: true,
            //     physics: NeverScrollableScrollPhysics(),
            //     itemCount: categories.length,
            //     itemBuilder: (context, index) {
            //       String category = categories[index];
            //       List<Map<String, dynamic>> communities = communityCards[category] ?? [];

            //       return Padding(
            //         padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(
            //               category,
            //               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
            //             ),
            //             SizedBox(height: 10),
            //             SingleChildScrollView(
            //               scrollDirection: Axis.horizontal,
            //               child: Row(
            //                 children: communities.map((community) {
            //                   return GestureDetector(
            //                     onTap: () {
            //                       // Navigator.push(
            //                       //   context,
            //                       //   MaterialPageRoute(
            //                       //     builder: (context) => const CommunityProfilePage(),
            //                       //   ),
            //                       // );
            //                     },
            //                     child: Padding(
            //                       padding: const EdgeInsets.only(right: 10.0),
            //                       child: Container(
            //                         padding: const EdgeInsets.only(top:7 ),
            //                         width: 120,
            //                         decoration: BoxDecoration(
            //                           border: Border.all(color: Colors.white.withOpacity(0.6)),
            //                           borderRadius: BorderRadius.circular(12),
            //                           boxShadow: [
            //                             BoxShadow(
            //                               color: Colors.black.withOpacity(0.4),
            //                               blurRadius: 6,
            //                               offset: Offset(0, 3),
            //                             ),
            //                           ],
            //                         ),
            //                         child: Column(
            //                           children: [
            //                             CircleAvatar(
            //                               radius: 30,
            //                               backgroundImage: NetworkImage(community['profilePicUrl']!),
            //                             ),
            //                             SizedBox(height: 5),
            //                             Text(
            //                               community['communityName']!,
            //                               textAlign: TextAlign.center,
            //                               style: TextStyle(color: Colors.white),
            //                             ),
            //                           ],
            //                         ),
            //                       ),
            //                     ),
            //                   );
            //                 }).toList(),
            //               ),
            //             ),
            //           ],
            //         ),
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
