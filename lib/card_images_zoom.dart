import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageZoom extends StatefulWidget {
  List<String> imageUrls;
   ImageZoom({super.key,required this.imageUrls});

  @override
  State createState() => _ImageZoomState();
}

class _ImageZoomState extends State<ImageZoom> {
  //  List<String> imageUrls = [
  //   'https://images.pexels.com/photos/674010/pexels-photo-674010.jpeg?cs=srgb&dl=pexels-anjana-c-169994-674010.jpg&fm=jpg',
  //   'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_640.jpg',
  //   'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&q=80&w=800',
  //   'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&q=80&w=750',
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black26,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: CarouselSlider.builder(
          itemCount: widget.imageUrls.length,
          itemBuilder: (context, imageIndex, realIndex) {
            return ClipRRect(
              child: PhotoView(
                imageProvider: NetworkImage(widget.imageUrls[imageIndex]),
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black26,
                ),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3.0,
                initialScale: PhotoViewComputedScale.contained,
                basePosition: Alignment.center,
                enableRotation: true,
                heroAttributes:
                    PhotoViewHeroAttributes(tag: widget.imageUrls[imageIndex]),
                onScaleEnd: (context, details, value) {},
                gestureDetectorBehavior: HitTestBehavior.opaque,
              ),
            );
          },
          options: CarouselOptions(
            enableInfiniteScroll: false,
            viewportFraction: 1,
            aspectRatio: 4 / 5,
          ),
        ),
      ),
    );
  }
}
