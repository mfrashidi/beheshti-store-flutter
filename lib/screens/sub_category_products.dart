import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nama_kala/screens/product_screen.dart';
import 'package:shimmer/shimmer.dart';

import '../assets/item_card.dart';

String subCategoryId = "";
Map<String, dynamic> category = {};
Map<String, dynamic> subCategory = {};
Map<String, dynamic> products = {};
List<String> productIds = [];

class SubCategoryScreen extends StatefulWidget {
  SubCategoryScreen(String id) {
    subCategoryId = id;
  }

  @override
  _SubCategoryScreenState createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {

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

  Future<void> _getCategory() async {
    String result;

    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_CATEGORY=" + subCategoryId.split("_")[0] + "\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        result = utf8.decode(response);
        final data = await json.decode(result);
        setState(() {
          category = data;
          subCategory = category["sub_categories"][subCategoryId.split("_")[1]];
          List<dynamic> pIDs = json.decode(subCategory["products"]);
          productIds = [];
          for (var p in pIDs) {
            productIds.add(p.toString());
          }
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getCategory();
  }

  @override
  Widget build(BuildContext context) {
    // Map<String, dynamic> filteredProducts = Map.from(products)..removeWhere((k, v) => !v["category_id"].toString().endsWith(subCategoryId));
    // List<String> productIds = [];
    // for (var k in filteredProducts.keys) {
    //   productIds.add(k);
    // }
    return Scaffold(
        appBar: AppBar(
            flexibleSpace: SafeArea(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: subCategory.isNotEmpty ? Icon(LineIcons.byName(subCategory["icon"]), size: 30) :
                  SizedBox(
                    width: 30.0,
                    height: 30.0,
                    child: Shimmer.fromColors(
                        baseColor: Colors.white,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: 10.0,
                          height: 10.0,
                          color: Colors.white,
                        )
                    ),
                  ),
                ),
              ),
            ),
            title: (category.isNotEmpty && subCategory.isNotEmpty) ? Column(
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
            ) : SizedBox(
              width: 10.0,
              height: 10.0,
              child: Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 75.0,
                    height: 30.0,
                    color: Colors.white,
                  )
              ),
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
                              child: FutureBuilder<Map<String, dynamic>>(
                                  future: getProduct(productIds[index]),
                                  builder: (context, AsyncSnapshot<Map<String, dynamic>> product) {
                                    if (product.hasData) {
                                      return Container(
                                        padding: EdgeInsets.all(10),
                                        child: getItemCard(
                                            product.data?["image"],
                                            product.data?["name"],
                                            product.data?["price"]),
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
                              ),
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