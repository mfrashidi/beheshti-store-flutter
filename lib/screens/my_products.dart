import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nama_kala/screens/add_new_product_screen.dart';
import 'package:nama_kala/screens/product_screen.dart';

import '../assets/item_card.dart';

Map<String, dynamic> products = {};
Map<String, dynamic> user = {};

class MyProductScreen extends StatefulWidget {
  const MyProductScreen({Key? key}) : super(key: key);
  @override
  _MyProductScreenState createState() => _MyProductScreenState();
}

class _MyProductScreenState extends State<MyProductScreen> {

  Future<void> _getProducts() async {
    final String response = await rootBundle.loadString('assets/products.json');
    final data = await json.decode(response);
    setState(() {
      products = data;
    });
  }

  Future<void> _getUser() async {
    final String response = await rootBundle.loadString('assets/user.json');
    final data = await json.decode(response);
    setState(() {
      user = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _getProducts();
    _getUser();
  }

  Widget _myProducts() {
    Map<String, dynamic> filteredProducts = Map.from(products)..removeWhere((k, v) => v["owner"] != user["user_id"]);
    List<String> productIds = [];
    for (var k in filteredProducts.keys) {
      productIds.add(k);
    }
    return productIds.isEmpty ? Container() : ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Container(
          height: 250,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 20),
              itemCount: productIds.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: Padding(
                      padding: EdgeInsets.only(right: index == 0 ? 25 : 5, left: index == productIds.length - 1 ? 25 : 5),
                      child: SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(CupertinoPageRoute(builder: (context) => AddNewProductScreen(products[productIds[index]])));
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
                                padding: EdgeInsets.all(10),
                                child: products.isNotEmpty ? getItemCard(
                                    products[productIds[index]]["image"],
                                    products[productIds[index]]["name"],
                                    products[productIds[index]]["price"]) : Container(),
                              ),
                            )
                        ),
                      )),
                );
              }
          ),
        ),
        SizedBox(height: 30)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
                "کالاهای من",
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
                  child: Icon(LineIcons.box, size: 30),
                ),
              ),
            ),
        ),
      body: Stack(
        children: [
          _myProducts(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (context) => AddNewProductScreen()));
                },
                style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    shadowColor: Colors.black.withOpacity(0.5),
                    fixedSize: Size(double.infinity, 60),
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10),
                    )
                ),
                child:
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "اضافه کردن کالای جدید",
                          style: TextStyle(fontFamily: 'Beheshti', fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.add),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  
}