import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medlink/constant/image_string.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body:ImageSlider() ,
    );
  }
}


//SLIDE CARAUSEL SLIDER
class ImageSlider extends StatefulWidget {
  const ImageSlider({Key? key}) : super(key: key);
  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final myitems=[
    Image.asset(slide1),Image.asset(slide2),Image.asset(slide3),Image.asset(slide5),Image.asset(slide6),
  ];

  int myCurrentIndex=0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
            items: myitems,
            options: CarouselOptions(
              autoPlay: true,
              height: 200,
              autoPlayCurve: Curves.fastOutSlowIn,
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayInterval: const Duration(seconds: 2),
              enlargeCenterPage: true,
              aspectRatio: 2.0,
              onPageChanged: (index,reason){
                setState(() {
                  myCurrentIndex=index;
                });
              },

            ),
        ),
        AnimatedSmoothIndicator(
          activeIndex: myCurrentIndex,
          count: myitems.length,
          effect:WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            spacing: 10,
            activeDotColor: Colors.blue.shade700,
            dotColor: Colors.grey.shade200,
            paintStyle: PaintingStyle.fill,
        ),
      )
      ],
    );
  }
}

