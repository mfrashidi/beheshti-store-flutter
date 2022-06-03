import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nama_kala/assets/item_card.dart';
import '../customized_libs/search_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

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

  @override
  Widget build(BuildContext context) {
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

  List<Map<String, dynamic>> specialOffers = [
    {"image": "assets/screens/home/special_offer/dell.jpeg",
      "name": "کامپیوتر همه کاره 23.8 اینچ دل مدل 5470-B",
      "price": "۱۷,۱۶۰,۰۰۰",
    },
    {"image": "assets/screens/home/special_offer/book.jpeg",
      "name": "کتاب پاستیل های بنفش اثر کاترین اپل گیت نشر آبیژ",
      "price": "۲۱,۹۰۰",
    },
    {"image": "assets/screens/home/special_offer/converse.jpeg",
      "name": "کفش راحتی کانورس مدل ALL STAR HIGH BL",
      "price": "۸۵۵,۰۰۰",
    },
    {"image": "assets/screens/home/special_offer/bike.jpeg",
      "name": "دوچرخه برقی هیمو مدل C26 SUN3658 سایز 26",
      "price": "۴۲,۰۰۰,۰۰۰",
    },
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
                            padding: EdgeInsets.only(right: 5, left: 5),
                            child: index == 0 ?
                            new Image.asset("assets/screens/home/special_offer/banner.png",
                              width: 150,
                            ) : SlideAnimation(
                    horizontalOffset: 50.0,child:FadeInAnimation(child: getItemCard(specialOffers[index - 1]["image"],
                                specialOffers[index - 1]["name"],
                                specialOffers[index - 1]["price"])),
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
                      Stack(
                        children: [
                          Text(
                              "لپ تاپ 16.2 اینچی اپل مدل MacBook Pro Mk183 2021",
                              style: TextStyle(
                                  fontFamily: 'Beheshti',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.black
                              )
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 50,
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
                                          fontSize: 22,
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
                        ],
                      ),
                      new Image.asset(
                        "assets/screens/home/best_seller/macbook.jpeg",
                      )
                    ],
                  ),
                )
              ],
            ),
        )
      ],
    ));
  }
}
