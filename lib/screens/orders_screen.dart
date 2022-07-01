import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:line_icons/line_icons.dart';
import 'package:expandable/expandable.dart';
import 'package:nama_kala/screens/product_screen.dart';
import 'package:nama_kala/utils/converter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shamsi_date/shamsi_date.dart';

Map<String, dynamic> products = {};
Map<String, dynamic> user = {};

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_ME\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        final data = await json.decode(utf8.decode(response));
        setState(() {
          user = data;
        });
      });
    });
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

  Future<Map<String, dynamic>> _getOrder(String orderID) async {
    Completer<Map<String, dynamic>> _completer = Completer<Map<String, dynamic>>();
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_ORDER=" + orderID + "\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        _completer.complete(json.decode(utf8.decode(response)));
      });
    });

    return _completer.future;
  }

  Widget _cart(int index) {
    int orderIndex = index;
    return AnimationLimiter(
        child: FutureBuilder<Map<String, dynamic>>(
            future: _getOrder(user["orders"][index]),
            builder: (context, AsyncSnapshot<Map<String, dynamic>> order) {
              return order.hasData ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: order.data!["products"].length,
                  itemBuilder: (context, productIndex) {
                    return AnimationConfiguration.staggeredList(
                      position: productIndex,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: -50.0,
                        child: FadeInAnimation(
                            child: FutureBuilder<Map<String, dynamic>>(
                              future: getProduct(order.data!["products"][productIndex].split("@")[0]),
                              builder: (context, AsyncSnapshot<Map<String, dynamic>> product) {
                                return product.hasData ? Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    children: [
                                      GridView(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.7,
                                          crossAxisSpacing: 30,
                                          mainAxisSpacing: 30,
                                        ),
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(CupertinoPageRoute(builder: (context) => ProductScreen(order.data!["products"][productIndex].split("@")[0])));
                                            },
                                            child: Image.memory(Uint8List.fromList(base64Decode(product.data!["image"]))),
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
                                                        product.data!["name"],
                                                        style: TextStyle(
                                                            fontFamily: 'Beheshti',
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 15,
                                                            color: Colors.black
                                                        )
                                                    ),
                                                    SizedBox(height: 5),
                                                    product.data!["has_color"] ?
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 7,
                                                          backgroundColor: Color(int.parse(product.data!["colors"][int.parse(order.data!["products"][productIndex].split("@")[2])]["code"])).withAlpha(150),
                                                          child: CircleAvatar(radius: 5, backgroundColor: Color(int.parse(product.data!["colors"][int.parse(order.data!["products"][productIndex].split("@")[2])]["code"])) == Color(0xffffffff) ? Colors.grey : Color(int.parse(product.data!["colors"][int.parse(order.data!["products"][productIndex].split("@")[2])]["code"]))),
                                                        ),
                                                        SizedBox(width: 5),
                                                        Text(
                                                            product.data!["colors"][int.parse(order.data!["products"][productIndex].split("@")[2])]["name"],
                                                            style: TextStyle(
                                                                fontFamily: 'Beheshti',
                                                                fontWeight: FontWeight.normal,
                                                                fontSize: 12,
                                                                color: Colors.black
                                                            )
                                                        )
                                                      ],
                                                    ) : Container(),
                                                    SizedBox(height: 5),
                                                    product.data!["has_size"] ?
                                                    Row(
                                                      children: [
                                                        Text(
                                                            "سایز:",
                                                            style: TextStyle(
                                                                fontFamily: 'Beheshti',
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 12,
                                                                color: Colors.black
                                                            )
                                                        ),
                                                        SizedBox(width: 5),
                                                        Text(
                                                            product.data!["sizes"][int.parse(order.data!["products"][productIndex].split("@")[3])].toString(),
                                                            style: TextStyle(
                                                                fontFamily: 'Beheshti',
                                                                fontWeight: FontWeight.normal,
                                                                fontSize: 12,
                                                                color: Colors.black
                                                            )
                                                        )
                                                      ],
                                                    ) : Container(),
                                                    SizedBox(height: 15),
                                                    Row(
                                                      children: [
                                                        Text(
                                                            "تعداد:",
                                                            style: TextStyle(
                                                                fontFamily: 'Beheshti',
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 12,
                                                                color: Colors.black
                                                            )
                                                        ),
                                                        SizedBox(width: 5),
                                                        Text(
                                                            persianNumber(int.parse(order.data!["products"][productIndex].split("@")[1])),
                                                            style: TextStyle(
                                                                fontFamily: 'Beheshti',
                                                                fontWeight: FontWeight.normal,
                                                                fontSize: 12,
                                                                color: Colors.black
                                                            )
                                                        )
                                                      ],
                                                    ),
                                                    SizedBox(height: 15),
                                                    Stack(
                                                      children: [
                                                        Align(
                                                          alignment: Alignment.bottomCenter,
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            children: <Widget>[
                                                              Text(
                                                                  persianNumber(product.data!["price"]),
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
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      productIndex == order.data!["products"].length - 1 ?
                                          Row(
                                            children: [
                                              Image.asset("assets/screens/profile/address.png", width: 25),
                                              SizedBox(width: 5),
                                              Text(
                                                  user["addresses"][order.data!["address_index"]]["title"],
                                                  style: TextStyle(
                                                      fontFamily: 'Beheshti',
                                                      fontWeight: FontWeight.w900,
                                                      fontSize: 14,
                                                      color: Colors.black
                                                  )
                                              ),
                                              SizedBox(width: 15),
                                              Container(
                                                width: 225,
                                                child: Text(
                                                    user["addresses"][order.data!["address_index"]]["address"],
                                                    style: TextStyle(
                                                        fontFamily: 'Beheshti',
                                                        fontWeight: FontWeight.normal,
                                                        fontSize: 12,
                                                        color: Colors.black
                                                    )
                                                ),
                                              ),
                                              SizedBox(height: 60),
                                            ],
                                          )
                                          : Container(),
                                      productIndex != order.data!["products"].length - 1  ? Row(
                                        children: List.generate(400~/10, (index) => Expanded(
                                          child: Container(
                                            color: index%2==0?Colors.transparent
                                                :Colors.grey,
                                            height: 1,
                                          ),
                                        )),
                                      ) : Container(),
                                      productIndex == order.data!["products"].length - 1  ? Stack(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                "جمع کل",
                                                style: TextStyle(
                                                    fontFamily: 'Beheshti',
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 17,
                                                    color: Colors.black
                                                )
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                Text(
                                                    persianNumber(order.data!["total_price"]),
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
                                          ),
                                        ],
                                      ) : Container()
                                    ],
                                  ),
                                ) : Container();
                              },
                            )
                        ),
                      ),
                    );
                  }
              ) : CircularProgressIndicator(color: Colors.grey.shade300);
            }
        )

    );
  }

  Widget _orderWidget() {
    List orders = user.isNotEmpty ? user["orders"] : [];
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: orders.length,
        itemBuilder: (context, index) {
          return ListView(
              shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                  BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: Offset(0, 10), // changes position of shadow
                  ),
                  ],
                  ),
                  child: ExpandablePanel(
                      header: FutureBuilder<Map<String, dynamic>>(
                        future: _getOrder(orders[index]),
                        builder: (context, AsyncSnapshot<Map<String, dynamic>> order) {
                          if(order.hasData) {
                            Jalali orderDate = Jalali.fromDateTime(DateTime.fromMillisecondsSinceEpoch(order.data!["order_time"] * 1000));
                            return Text(
                                "سفارش " + orderDate.formatter.wN + " " + persianNumber(int.parse(orderDate.formatter.d)) + " " + orderDate.formatter.mN,
                                style: TextStyle(
                                    fontFamily: 'Beheshti',
                                    fontWeight: FontWeight.normal,
                                    fontSize: 17,
                                    color: Colors.black
                                )
                            );
                          } else {
                            return SizedBox(
                              width: 100.0,
                              height: 60.0,
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
                        }),
                      collapsed: Container(),
                      expanded: _cart(index),
                  ),
                ),
                SizedBox(height: 30)
              ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "سفارش ها",
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
              child: Icon(LineIcons.list, size: 25),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        shrinkWrap: true,
        children: [
          _orderWidget()
        ],
      ),
    );
  }
  
}