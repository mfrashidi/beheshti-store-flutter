import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nama_kala/screens/add_new_product_screen.dart';
import 'package:nama_kala/screens/product_screen.dart';
import 'package:nama_kala/screens/profile_screen.dart';
import 'package:shimmer/shimmer.dart';

import '../assets/item_card.dart';

Map<String, dynamic> products = {};
Map<String, dynamic> user = {};
List<String> productIds = [];

class MyProductScreen extends StatefulWidget {
  const MyProductScreen({Key? key}) : super(key: key);
  @override
  _MyProductScreenState createState() => _MyProductScreenState();
}

class _MyProductScreenState extends State<MyProductScreen> {

  Future<void> _getMyProducts() async {
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_MY_PRODUCTS\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        final data = await json.decode(utf8.decode(response));
        productIds = [];
        setState(() {
          for (var i in data) {
            productIds.add(i.toString());
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
    _getMyProducts();
  }

  Widget _myProducts() {
    return Container(
      padding: EdgeInsets.all(20),
      child: GridView.builder(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 15,
            mainAxisSpacing: 20,
          ),
          itemCount: productIds.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: Padding(
                  padding: EdgeInsets.all(0),
                  child:  FutureBuilder<Map<String, dynamic>>(
                      future: getProduct(productIds[index]),
                      builder: (context, AsyncSnapshot<Map<String, dynamic>> product) {
                        return SlideAnimation(
                          horizontalOffset: 50.0,
                          child: FadeInAnimation(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(CupertinoPageRoute(builder: (context) => AddNewProductScreen(product.data!)));
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
                                  child: product.hasData ? getItemCard(
                                      product.data!["image"],
                                      product.data!["name"],
                                      product.data!["price"]) : SizedBox(
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
                                ),
                              )
                          ),
                        );})),
            );
          }
      ),
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