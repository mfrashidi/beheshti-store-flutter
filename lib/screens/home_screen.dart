import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nama_kala/assets/item_card.dart';
import '../customized_libs/search_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

Map<String, dynamic> products = {};

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen()
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showLogo = true;
  TextEditingController textController = TextEditingController();


  Future<void> getProducts() async {
    final String response = await rootBundle.loadString('assets/products.json');
    final data = await json.decode(response);
    setState(() {
      products = data;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) getProducts();
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: AnimSearchBar(
                    width: MediaQuery.of(context).size.width - 40,
                    rtl: true,
                    helpText: "جستجو",
                    closeSearchOnSuffixTap: true,
                    autoFocus: true,
                    style: TextStyle(
                        fontFamily: 'Beheshti',
                        fontWeight: FontWeight.normal,
                        fontSize: 17,
                        color: Colors.black
                    ),
                    // autoFocus: true,
                    textController: textController,
                    onSuffixTap: () {
                      setState(() {
                        showLogo = false;
                      });
                      textController.clear();
                    },
                    onCloseBar: () {
                      setState(() {
                        showLogo = true;
                      });
                    }
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: AnimatedOpacity(
                  opacity: showLogo ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 100),
                  child: Image.asset('assets/Beheshti.png', width: 150.0),
                ),
              )
            ],
          ),
        ),
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Body(),
    );
  }
}
class Body extends StatelessWidget {
  var images = [
    "assets/screens/home/banner_1.jpeg",
    "assets/screens/home/banner_2.jpeg",
    "assets/screens/home/banner_3.jpeg",
    "assets/screens/home/banner_4.jpeg",
  ];

  List<String> specialOffers = [
    "26c0a9b017",
    "53a829e24d",
    "0e3982c7bb",
    "e087af427e"
  ];

  List<String> newArrivals = [
    "51d7aa3a08",
    "0a265bf1a8",
    "ac28f88fbc",
    "8adfc0d358"
  ];

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter( child: ListView(
      physics: BouncingScrollPhysics(),
      children: [
        CarouselSlider(
          options: CarouselOptions(
              height: 200.0,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              enlargeCenterPage: true,

          ),
          items: images.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              spreadRadius: -10.0,
                              blurRadius: 10.0,
                              offset: Offset(0.0, 10.0),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.asset(i, fit: BoxFit.cover),
                        ),
                    ),
                );
              },
            );
          }).toList(),
        ),

          Container(
                height: 250,
                color: Color(0xffE6123D),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  itemCount: specialOffers.length + 1,
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: Padding(
                          padding: EdgeInsets.only(right: 5, left: index == specialOffers.length ? 20 : 5),
                          child: index == 0 ?
                          new Image.asset("assets/screens/home/special_offer/banner.png",
                            width: 150,
                          ) : SlideAnimation(
                            horizontalOffset: 50.0,
                            child: FadeInAnimation(
                                child: Container(
                                  width: 165,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(index - 1 == 0 ? 5 : 1),
                                      topLeft: Radius.circular(index == specialOffers.length ? 5 : 1),
                                      bottomLeft: Radius.circular(index == specialOffers.length ? 5 : 1),
                                      bottomRight: Radius.circular(index - 1 == 0 ? 5 : 1),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 0,
                                        blurRadius: 10,
                                        offset: Offset(0, 10), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: products.isNotEmpty ? getItemCard(
                                      products[specialOffers[index - 1]]["image"],
                                      products[specialOffers[index - 1]]["name"],
                                      products[specialOffers[index - 1]]["price"]) : Container()
                                  ,
                                )
                            ),
                          )),
                    );
                  }
                ),

        ),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              "پرفروش‌ترین هفته",
                              style: TextStyle(
                                  fontFamily: 'Beheshti',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: Colors.black
                              )
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(
                              LineIcons.award,
                              size: 30,
                          ),
                        )
                      ],
                    ),
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: GridView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 30,
                    ),
                    children: [
                      new Image.asset(
                        "assets/screens/home/best_seller/macbook.jpeg",
                      ),
                      Stack(
                        children: [
                          Text(
                              "لپ تاپ 16.2 اینچی اپل مدل MacBook Pro Mk183 2021",
                              style: TextStyle(
                                  fontFamily: 'Beheshti',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black
                              )
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              height: 23,
                              child: ListView(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                children: [
                                  Text(
                                      "۷۶,۹۰۰,۰۰۰",
                                      style: TextStyle(
                                          fontFamily: 'Beheshti',
                                          fontWeight: FontWeight.normal,
                                          fontSize: 18,
                                          color: Colors.black
                                      )
                                  ),
                                  Text(
                                      "تومان",
                                      style: TextStyle(
                                          fontFamily: 'Beheshti',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                          color: Colors.black
                                      )
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                              alignment: Alignment.bottomRight,
                              child: Icon(CupertinoIcons.cart_badge_plus,
                                size: 22,
                                color: Color(0xFF207D4C),)
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
        ),
        Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 20, right: 25, left: 25),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            "کالاهای جدید",
                            style: TextStyle(
                                fontFamily: 'Beheshti',
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: Colors.black
                            )
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          LineIcons.truck,
                          size: 30,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 250,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(vertical: 20),
                      itemCount: newArrivals.length,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: Padding(
                              padding: EdgeInsets.only(right: index == 0 ? 25 : 5, left: index == specialOffers.length - 1 ? 25 : 5),
                              child: SlideAnimation(
                                horizontalOffset: 50.0,
                                child: FadeInAnimation(
                                    child: Container(
                                      width: 165,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            spreadRadius: 0,
                                            blurRadius: 10,
                                            offset: Offset(0, 10), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: products.isNotEmpty ? getItemCard(
                                          products[newArrivals[index]]["image"],
                                          products[newArrivals[index]]["name"],
                                          products[newArrivals[index]]["price"]) : Container(),
                                    )
                                ),
                              )),
                        );
                      }
                  ),
                )
              ],
            ),
        )
      ],
    )
    );
  }
}
