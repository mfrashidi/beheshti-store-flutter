import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nama_kala/screens/product_screen.dart';

List<dynamic> items = [];
Map<String, dynamic> products = {};

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {

  Future<void> _getProducts() async {
    final String response = await rootBundle.loadString('assets/products.json');
    final data = await json.decode(response);
    setState(() {
      products = data;
    });
  }

  Future<void> _getFavorites() async {
    final String response = await rootBundle.loadString('assets/user.json');
    final data = await json.decode(response);
    setState(() {
      items = data["favorites"];
    });
  }

  @override
  void initState() {
    super.initState();
    _getFavorites();
    _getProducts();
  }

  Widget _favoriteProducts() {
    return AnimationLimiter(
        child: ListView.separated(
            separatorBuilder: (context, index) => SizedBox(
              height: 20,
            ),
            padding: EdgeInsets.all(20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> product = products[items[index]];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: -50.0,
                  child: FadeInAnimation(
                      child: Container(
                        padding: EdgeInsets.all(10),
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
                        child: GridView(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.3,
                            crossAxisSpacing: 30,
                            mainAxisSpacing: 30,
                          ),
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(CupertinoPageRoute(builder: (context) => ProductScreen(items[index])));
                              },
                              child: new Image.asset(product["image"]),
                            ),
                            Stack(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: ListView(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    children: [
                                      Text(
                                          product["name"],
                                          style: TextStyle(
                                              fontFamily: 'Beheshti',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black
                                          )
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 14,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                              "موجود در انبار",
                                              style: TextStyle(
                                                  fontFamily: 'Beheshti',
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12,
                                                  color: Colors.black
                                              )
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15),
                                      Stack(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  items.remove(items[index]);
                                                });
                                              },
                                              child: Icon(LineIcons.trash, color: Colors.redAccent,),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                Text(
                                                    product["price"],
                                                    style: TextStyle(
                                                        fontFamily: 'Beheshti',
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 18,
                                                        color: Colors.black
                                                    )
                                                ),
                                                Text(
                                                    "تومان",
                                                    style: TextStyle(
                                                        fontFamily: 'Beheshti',
                                                        fontWeight: FontWeight.normal,
                                                        fontSize: 10,
                                                        color: Colors.black
                                                    )
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 15),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                  ),
                ),
              );
            }
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "علاقه‌مندی های من",
            style: TextStyle(
                fontFamily: 'Beheshti',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black
            )
        ),
        toolbarHeight: 80,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white.withOpacity(0.3),
        elevation: 0,
        flexibleSpace: SafeArea(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: Icon(LineIcons.heart, size: 25),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          _favoriteProducts()
        ],
      ),
    );
  }
}