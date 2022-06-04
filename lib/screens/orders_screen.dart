import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:line_icons/line_icons.dart';
import 'package:expandable/expandable.dart';
import 'package:nama_kala/screens/product_screen.dart';

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
    _getProducts();
    _getUser();
  }

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

  Widget _cart(int index) {
    int orderIndex = index;
    List items = user["orders"][index]["products"];
    return AnimationLimiter(
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
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
                                          product["has_color"] ?
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 7,
                                                backgroundColor: Color(int.parse(product["colors"][0]["code"])).withAlpha(150),
                                                child: CircleAvatar(radius: 5, backgroundColor: Color(int.parse(product["colors"][0]["code"])) == Color(0xffffffff) ? Colors.grey : Color(int.parse(product["colors"][0]["code"]))),
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                  product["colors"][0]["name"],
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
                                          product["has_size"] ?
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
                                                  product["sizes"][0],
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
                                          Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.bottomCenter,
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
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            index != items.length - 1  ? Row(
                              children: List.generate(400~/10, (index) => Expanded(
                                child: Container(
                                  color: index%2==0?Colors.transparent
                                      :Colors.grey,
                                  height: 1,
                                ),
                              )),
                            ) : Container(),
                            index == items.length - 1  ? Stack(
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
                                          user["orders"][orderIndex]["total_price"],
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
                      )
                  ),
                ),
              );
            }
        )
    );
  }

  Widget _orderWidget() {
    List orders = user["orders"];
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
                      header: Text(
                      "سفارش " + orders[index]["date"],
                      style: TextStyle(
                      fontFamily: 'Beheshti',
                      fontWeight: FontWeight.normal,
                      fontSize: 17,
                      color: Colors.black
                      )
                      ),
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