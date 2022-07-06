import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';
import 'package:beheshti_store/screens/product_screen.dart';
import 'package:beheshti_store/utils/converter.dart';
import 'package:shimmer/shimmer.dart';

List<dynamic> items = [];
Map<String, dynamic> products = {};

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {


  Future<Map<String, dynamic>> getProduct(String productId) async {
    Completer<Map<String, dynamic>> _completer = Completer<Map<String, dynamic>>();
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_PRODUCT=" + productId + "\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        Map<String, dynamic> data = json.decode(utf8.decode(response));
        data["image"] = await _getImage(data["image"]);
        _completer.complete(data);
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

  Future<void> _getFavorites() async {
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_ME\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        final data = await json.decode(utf8.decode(response));
        setState(() {
          items = data["favorites"];
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getFavorites();
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
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: -50.0,
                  child: FadeInAnimation(
                      child: FutureBuilder<Map<String, dynamic>>(
                          future: getProduct(items[index]),
                          builder: (context, AsyncSnapshot<Map<String, dynamic>> product) {
                          return Container(
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
                            product.hasData ? GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(CupertinoPageRoute(builder: (context) => ProductScreen(items[index])));
                              },
                              child: Image.memory(Uint8List.fromList(base64Decode(product.data!["image"]))),
                            ) : SizedBox(
                                width: 10.0,
                                height: 10.0,
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
                            Stack(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: ListView(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    children: [
                                      product.hasData ? Text(
                                          product.data!["name"],
                                          style: TextStyle(
                                              fontFamily: 'Beheshti',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black
                                          )
                                      ) : SizedBox(
                                        width: 10.0,
                                        height: 10.0,
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
                                      SizedBox(height: 5),
                                      product.hasData ? Row(
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
                                      ) : SizedBox(height: 20),
                                      SizedBox(height: 15),
                                      Stack(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: GestureDetector(
                                              onTap: () async {
                                                await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
                                                  String token = await getToken() ?? "nothing";
                                                  serverSocket.write("AUTH=" + token + ";REMOVE_FAVORITE=" + items[index] + "\n");
                                                  serverSocket.flush();
                                                  serverSocket.listen((response) async {
                                                    String result = utf8.decode(response);
                                                    if (result == "DONE") {
                                                      Fluttertoast.showToast(
                                                        msg: "محصول از علاقه‌مندی‌های شما حذف شد",
                                                        toastLength: Toast.LENGTH_LONG,
                                                        timeInSecForIosWeb: 1,
                                                        gravity: ToastGravity.CENTER,
                                                        backgroundColor: Colors.redAccent,
                                                        textColor: Colors.white,
                                                        fontSize: 16.0,
                                                      );
                                                    }
                                                  });
                                                });
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
                                                product.hasData ? Text(
                                                    persianNumber(product.data!["price"]),
                                                    style: TextStyle(
                                                        fontFamily: 'Beheshti',
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 18,
                                                        color: Colors.black
                                                    )
                                                ) : SizedBox(
                                                  width: 50.0,
                                                  height: 10.0,
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
                      );}
                  ),
                ),
              ));
            }
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "علاقه‌مندی ها",
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