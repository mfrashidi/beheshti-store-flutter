import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nama_kala/screens/product_screen.dart';
import 'package:nama_kala/screens/sub_category_products.dart';

import '../assets/item_card.dart';

String categoryId = "";
Map<String, dynamic> category = {};
Map<String, dynamic> products = {};


class CategoryScreen extends StatefulWidget {
  CategoryScreen(String id) {
    categoryId = id;
  }

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>{

  Future<void> _getCategory() async {
    final String response = await rootBundle.loadString('assets/categories.json');
    final data = await json.decode(response);
    setState(() {
      category = data[categoryId];
    });
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
    _getCategory();
    _getProducts();
  }

  Widget subCategoriesWidget(String subCategory) {
    Map<String, dynamic> filteredProducts = Map.from(products)..removeWhere((k, v) => v["category_id"] != categoryId + "_" + subCategory);
    List<String> productIds = [];
    for (var k in filteredProducts.keys) {
      productIds.add(k);
    }
    return productIds.isEmpty ? Container() : ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: EdgeInsets.only(right: 25, left: 25),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  children: [
                    Icon(
                      LineIcons.byName(category["sub_categories"][subCategory]["icon"]),
                      size: 30,
                    ),
                    SizedBox(width: 10),
                    Text(
                        category["sub_categories"][subCategory]["name"],
                        style: TextStyle(
                            fontFamily: 'Beheshti',
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: Colors.black
                        )
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(builder: (context) => SubCategoryScreen(categoryId+"_"+subCategory)));
                  },
                  child: Text(
                      "تمام کالاها",
                      style: TextStyle(
                          fontFamily: 'Beheshti',
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                          color: Colors.lightBlue
                      )
                  ),
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
                                Navigator.of(context).push(CupertinoPageRoute(builder: (context) => ProductScreen(productIds[index])));
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
    Map<String, dynamic> subCategories = category["sub_categories"];
    List<String> subCategoriesIds = [];
    for (String k in subCategories.keys) {
      subCategoriesIds.add(k);
    }
    return Scaffold(
      body: SafeArea(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: subCategories.length,
              itemBuilder: (context, index) {
                return subCategoriesWidget(subCategoriesIds[index]);
              }
          )
      ),
        appBar: AppBar(
            title: Text(
                category["name"],
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
            elevation: 0
        )
    );
  }
}