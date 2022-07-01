import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nama_kala/screens/product_screen.dart';
import 'package:nama_kala/screens/sub_category_products.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../assets/item_card.dart';

String categoryId = "";
Map<String, dynamic> category = {};
Map<String, dynamic> products = {};
Map<String, List<String>> productIDs = {};

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

Future<String?> getToken() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await _prefs;
  final String token = prefs.getString('token') ?? "empty";

  return token;
}

class CategoryScreen extends StatefulWidget {
  CategoryScreen(String id) {
    categoryId = id;
  }

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>{

  Future<void> _getProducts() async {
    final String response = await rootBundle.loadString('assets/products.json');
    final data = await json.decode(response);
    setState(() {
      products = data;
    });
  }

  Future<void> _getProductsByCategory() async {
    String result;
    Map<String, dynamic> subCategories = {};

    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_CATEGORY=" + categoryId + "\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        result = utf8.decode(response);
        final data = await json.decode(result);
        setState(() {
          category = data;
          subCategories = category["sub_categories"];
          for (String sub in subCategories.keys) {
            List<dynamic> pIDs = json.decode(subCategories[sub]["products"]);
            productIDs[sub] = [];
            for (var pID in pIDs) {
              productIDs[sub]?.add(pID.toString());
            }
          }
        });
      });
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


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _getProducts();
      await _getProductsByCategory();
    });
  }

  Widget subCategoriesWidget(String subCategory) {
    return productIDs[subCategory]?.length == 0 ? Container() : ListView(
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
              itemCount: productIDs[subCategory]?.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: Padding(
                      padding: EdgeInsets.only(right: index == 0 ? 25 : 5, left: index == (productIDs[subCategory]?.length)! - 1 ? 25 : 5),
                      child: SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(CupertinoPageRoute(builder: (context) => ProductScreen(productIDs[subCategory]![index])));
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
                                child: FutureBuilder<Map<String, dynamic>>(
                                        future: getProduct(productIDs[subCategory]![index]),
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
                                    )
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
    Map<String, dynamic> subCategories = {};
    List<String> subCategoriesIds = [];
    if (category.isNotEmpty) {
      subCategories = category["sub_categories"];
      for (String k in subCategories.keys) {
        subCategoriesIds.add(k);
      }
    }
    return Scaffold(
      body: SafeArea(
          child: subCategories.isNotEmpty ? ListView.builder(
              shrinkWrap: true,
              itemCount: subCategories.length,
              itemBuilder: (context, index) {
                return subCategoriesWidget(subCategoriesIds[index]);
              }
          ) : CircularProgressIndicator(color: Colors.grey.shade300,)
      ),
        appBar: AppBar(
            title: category.isNotEmpty ? Text(
                category["name"],
                style: TextStyle(
                    fontFamily: 'Beheshti',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black
                )
            ) : SizedBox(
              width: 70.0,
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