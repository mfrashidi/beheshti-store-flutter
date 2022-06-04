import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nama_kala/screens/product_screen.dart';

import '../assets/item_card.dart';

String subCategoryId = "";
Map<String, dynamic> category = {};
Map<String, dynamic> subCategory = {};
Map<String, dynamic> products = {};

class SubCategoryScreen extends StatefulWidget {
  SubCategoryScreen(String id) {
    subCategoryId = id;
  }

  @override
  _SubCategoryScreenState createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {

  Future<void> _getCategories() async {
    final String response = await rootBundle.loadString(
        'assets/categories.json');
    final data = await json.decode(response);
    setState(() {
      Map<String, dynamic> categoriesMap = data;
      category = categoriesMap[subCategoryId.split("_")[0]];
      subCategory = category["sub_categories"][subCategoryId.split("_")[1]];
    }
    );
  }

  Future<void> _getProducts() async {
    final String response = await rootBundle.loadString('assets/products.json');
    final data = await json.decode(response);
    setState(() {
      products = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _getCategories();
    _getProducts();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> filteredProducts = Map.from(products)..removeWhere((k, v) => !v["category_id"].toString().endsWith(subCategoryId));
    List<String> productIds = [];
    for (var k in filteredProducts.keys) {
      productIds.add(k);
    }
    return Scaffold(
        appBar: AppBar(
            flexibleSpace: SafeArea(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Icon(LineIcons.byName(subCategory["icon"]), size: 30),
                ),
              ),
            ),
            title: Column(
                children: <Widget>[
                  Text(
                      category["name"],
                      style: TextStyle(
                          fontFamily: 'Beheshti',
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: Colors.black
                      )
                  ),
                  SizedBox(width: 5),
                  Text(
                      subCategory["name"],
                      style: TextStyle(
                          fontFamily: 'Beheshti',
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                          color: Colors.black
                      )
                  ),
                ]
            ),
            leading: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.arrow_back_ios, color: Colors.black),
              ),
            ),
            toolbarHeight: 80,
            centerTitle: true,
            backgroundColor: Colors.white.withOpacity(0.3),
            elevation: 0
        ),
        body: SafeArea(
            child: GridView.builder(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 15,
              mainAxisSpacing: 0,
            ),
            itemCount: productIds.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: Padding(
                    padding: EdgeInsets.only(right: index == 0 ? 25 : 5, left: index == productIds.length - 1 ? 25 : 5),
                    child: SlideAnimation(
                      verticalOffset: -50.0,
                      child: FadeInAnimation(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(CupertinoPageRoute(builder: (context) => ProductScreen(productIds[index])));
                            },
                            child: Container(
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
        )
        )
    );
  }
}