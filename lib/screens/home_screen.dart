import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:beheshti_store/assets/item_card.dart';
import 'package:beheshti_store/screens/product_screen.dart';
import 'package:beheshti_store/utils/converter.dart';
import 'package:shimmer/shimmer.dart';
import '../customized_libs/search_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

Map<String, dynamic> products = {};
Map<String, dynamic> bestSeller = {};
List<String> newArrivals = [];
List<String> specialOffers = [];

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

  Future<Map<String, dynamic>> getProduct(String productId) async {
    Completer<Map<String, dynamic>> _completer = Completer<Map<String, dynamic>>();
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_PRODUCT=" + productId + "\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        _completer.complete(json.decode(utf8.decode(response)));
      });
    });

    return _completer.future;
  }

  Future<int> _getImageLength(String imageID) async {
    Completer<int> _completer = Completer<int>();
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_IMAGE_LENGTH=" + imageID + "\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        _completer.complete(int.parse(String.fromCharCodes(response)));
      });
    });
    return _completer.future;
  }

  Future<String> _getImage(String imageID) async {
    Completer<String> _completer = Completer<String>();
    String result = "";
    int length = await _getImageLength(imageID);
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_IMAGE=" + imageID + "\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        result += await String.fromCharCodes(response);
        if (result.length >= length) {
          _completer.complete(result);
        }
      });
    });
    return _completer.future;
  }

  Future<void> _getBestSeller() async {
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_BEST_SELLER\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        bestSeller = json.decode(utf8.decode(response));
        bestSeller["image"] = await _getImage(bestSeller["image"]);
        setState(() {
        });
      });
    });
  }

  Future<void> _getSpecialOffers() async {
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_SPECIAL_OFFERS\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        setState(() {
          List<dynamic> data = json.decode(utf8.decode(response));
          for (var p in data) {
            specialOffers.add(p.toString());
          }
        });
      });
    });
  }

  Future<void> _getNewArrivals() async {
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_NEW_ARRIVALS\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        setState(() {
          List<dynamic> data = json.decode(utf8.decode(response));
          for (var p in data) {
            newArrivals.add(p.toString());
          }
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    bestSeller = {};
    newArrivals = [];
    specialOffers = [];

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _getNewArrivals();
      await _getBestSeller();
      await _getSpecialOffers();
    });
  }


  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) getProducts();

    var images = [
      "assets/screens/home/banner_1.jpeg",
      "assets/screens/home/banner_2.jpeg",
      "assets/screens/home/banner_3.jpeg",
      "assets/screens/home/banner_4.jpeg",
    ];

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
      body: AnimationLimiter( child: ListView(
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
                itemCount: specialOffers.isNotEmpty ? specialOffers.length + 1 : 5,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: Padding(
                        padding: EdgeInsets.only(right: 5, left: index == specialOffers.length ? 30 : 5),
                        child: index == 0 ?
                        new Image.asset("assets/screens/home/special_offer/banner.png",
                          width: 150,
                        ) : SlideAnimation(
                          horizontalOffset: 50.0,
                          child: FadeInAnimation(
                              child: GestureDetector(
                                onTap: () {
                                  _showProductScreen(context, specialOffers[index - 1]);
                                },
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
                                  child: specialOffers.isNotEmpty ? FutureBuilder<Map<String, dynamic>>(
                                      future: getProduct(specialOffers[index - 1]),
                                      builder: (context, AsyncSnapshot<Map<String, dynamic>> product) {
                                        if (product.hasData) {
                                          return Container(
                                            padding: EdgeInsets.all(10),
                                            child: getItemCard(
                                                product.data?["image"],
                                                product.data?["name"],
                                                product.data?["price"])
                                          );
                                        } else {
                                          return SizedBox(
                                            width: 165.0,
                                            height: 250.0,
                                            child: Shimmer.fromColors(
                                                baseColor: Colors.white,
                                                highlightColor: Colors.grey.shade100,
                                                child: Container(
                                                  width: 500.0,
                                                  height: 500.0,
                                                  color: Colors.white,
                                                )
                                            ),
                                          );
                                        }
                                      }
                                  ) : SizedBox(
                                    width: 165.0,
                                    height: 250.0,
                                    child: Shimmer.fromColors(
                                        baseColor: Colors.white,
                                        highlightColor: Colors.grey.shade100,
                                        child: Container(
                                          width: 165.0,
                                          height: 250.0,
                                          color: Colors.white,
                                        )
                                    ),
                                  )
                                  ,
                                ),
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
                GestureDetector(
                      onTap: () {
                        if (bestSeller.isNotEmpty) {
                          _showProductScreen(context, bestSeller["product_id"]);
                        }
                      },
                      child: Container(
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
                            bestSeller.isNotEmpty && (bestSeller["image"] as String).length > 1000 ? Image.memory(Uint8List.fromList(base64Decode(bestSeller["image"]))) : SizedBox(
                              width: 75,
                              height: 75,
                              child: Shimmer.fromColors(
                                  baseColor: Colors.grey.shade50,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                    width: 500.0,
                                    height: 500.0,
                                    color: Colors.white,
                                  )
                              ),
                            ),
                            Stack(
                              children: [
                                bestSeller.isNotEmpty ? Text(
                                    bestSeller["name"],
                                    style: TextStyle(
                                        fontFamily: 'Beheshti',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.black
                                    )
                                ) : SizedBox(
                                  width: 125,
                                  height: 30,
                                  child: Shimmer.fromColors(
                                      baseColor: Colors.grey.shade50,
                                      highlightColor: Colors.grey.shade100,
                                      child: Container(
                                        width: 500.0,
                                        height: 500.0,
                                        color: Colors.white,
                                      )
                                  ),
                                ),
                                bestSeller.isNotEmpty ? Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Container(
                                    height: 23,
                                    child: ListView(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        Text(
                                            persianNumber(bestSeller["price"]),
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
                                ) : Container(),
                                bestSeller.isNotEmpty ? Align(
                                    alignment: Alignment.bottomRight,
                                    child: Icon(CupertinoIcons.cart_badge_plus,
                                      size: 22,
                                      color: Color(0xFF207D4C),)
                                ) : Container()
                              ],
                            )
                          ],
                        ),
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
                      itemCount: newArrivals.isNotEmpty ? newArrivals.length : 4,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: Padding(
                              padding: EdgeInsets.only(right: index == 0 ? 25 : 5, left: index == specialOffers.length - 1 ? 25 : 5),
                              child: SlideAnimation(
                                horizontalOffset: 50.0,
                                child: FadeInAnimation(
                                    child: GestureDetector(
                                    onTap: () {
                                    if (newArrivals.isNotEmpty) {
                                      _showProductScreen(context, newArrivals[index]);
                                    }
                                    },
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
                                        child: newArrivals.isNotEmpty ? FutureBuilder<Map<String, dynamic>>(
                                        future: getProduct(newArrivals[index]),
                                        builder: (context, AsyncSnapshot<Map<String, dynamic>> product) {
                                          if (product.hasData) {
                                            return Container(
                                              padding: EdgeInsets.all(10),
                                              child: getItemCard(
                                                  product.data?["image"],
                                                  product.data?["name"],
                                                  product.data?["price"])
                                            );
                                          } else {
                                            return SizedBox(
                                              width: 165.0,
                                              height: 250.0,
                                              child: Shimmer.fromColors(
                                                  baseColor: Colors.white,
                                                  highlightColor: Colors.grey.shade100,
                                                  child: Container(
                                                    width: 500.0,
                                                    height: 500.0,
                                                    color: Colors.white,
                                                  )
                                              ),
                                            );
                                          }
                                        }
                                    ) : SizedBox(
                                          width: 165.0,
                                          height: 250.0,
                                          child: Shimmer.fromColors(
                                              baseColor: Colors.white,
                                              highlightColor: Colors.grey.shade100,
                                              child: Container(
                                                width: 500.0,
                                                height: 500.0,
                                                color: Colors.white,
                                              )
                                          ),
                                        ),
                                    )
                                ),
                              )),
                        ));
                      }
                  ),
                )
              ],
            ),
          )
        ],
      )
      ),
    );
  }

  void _showProductScreen(BuildContext context, String id) {
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) => ProductScreen(id)));
  }
}
