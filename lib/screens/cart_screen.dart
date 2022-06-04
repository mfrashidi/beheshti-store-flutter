import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nama_kala/screens/product_screen.dart';

List<String> items = ["0e3982c7bb", "51d7aa3a08", "a4f2e210f6"];
Map<String, int> itemsCount = {
  "0e3982c7bb": 1,
  "51d7aa3a08": 2,
  "a4f2e210f6": 1
};
Map<String, dynamic> products = {};
Map<String, dynamic> user = {};
int activeAddress = 0;

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

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
    activeAddress = 0;
  }

  String persianize(String number) {
    List<String> persianNumbers = ["۰", "۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹" ];
    for (int i = 0; i < 10; i++) {
      number = number.replaceAll(i.toString(), persianNumbers[i]);
    }
    return number;
  }

  Widget emptyCart() {
    return Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                Image.asset(
                  "assets/screens/cart/empty_cart.png",
                  scale: 1.7,
                ),
                Text(
                  "سبد خریدتان خالی می‌باشد   :(",
                  style: TextStyle(fontFamily: 'Beheshti', fontWeight: FontWeight.bold, fontSize: 17),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ]
    );
  }

  Widget filledCart() {
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
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(CupertinoPageRoute(builder: (context) => ProductScreen(items[index])));
                    },
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
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 30,
                        mainAxisSpacing: 30,
                      ),
                      children: [
                        new Image.asset(product["image"]),
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
                                  Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black.withOpacity(0.1)),
                                        borderRadius: BorderRadius.all(Radius.circular(5))
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                itemsCount[items[index]] = itemsCount[items[index]]! + 1;
                                              });
                                            },
                                            child: Icon(Icons.add),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                              persianize(itemsCount[items[index]].toString()),
                                              style: TextStyle(
                                                  fontFamily: 'Beheshti',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: Colors.black
                                              )
                                          ),
                                        ),
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: GestureDetector(
                                              onTap: () {
                                                if (itemsCount[items[index]]! > 1) {
                                                  setState(() {
                                                    itemsCount[items[index]] = itemsCount[items[index]]! - 1;
                                                  });
                                                }
                                              },
                                              child: Icon(Icons.remove, color: itemsCount[items[index]] == 1 ? Colors.grey.shade400 : Colors.black),
                                            )
                                        )
                                      ],
                                    ),
                                  )
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
              )
          );
        }
    )
    );
  }

  Widget finializePurchase() {
    List addresses = user["addresses"];
    return DraggableScrollableSheet(
        maxChildSize: .8,
        initialChildSize: .12,
        minChildSize: .12,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: Offset(0, -10),
                  ),
                ]
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    SizedBox(height: 5),
                    Container(
                      alignment: Alignment.center,
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.all(Radius.circular(10))),
                      ),
                    ),
                    SizedBox(height: 10),
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              "جمع کل",
                              style: TextStyle(
                                  fontFamily: 'Beheshti',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                  color: Colors.black
                              )
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                  "۸۸,۷۴۳,۰۰۰",
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
                                      color: Colors.grey.withOpacity(0.75)
                                  )
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: List.generate(400~/10, (index) => Expanded(
                        child: Container(
                          color: index%2==0?Colors.transparent
                              :Colors.grey,
                          height: 1,
                        ),
                      )),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Image.asset(
                          "assets/screens/profile/address.png",
                          width: 25,
                        ),
                        SizedBox(width: 10),
                        Text(
                            "آدرسی جهت ارسال محصولات انتخاب کنید",
                            style: TextStyle(
                                fontFamily: 'Beheshti',
                                fontWeight: FontWeight.normal,
                                fontSize: 17,
                                color: Colors.black
                            )
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    ListView.separated(
                      separatorBuilder: (context, index) => SizedBox(
                        height: 10,
                      ),
                      shrinkWrap: true,
                      itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: (){
                              setState(() {
                                activeAddress = index;
                              });
                            },
                            child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    border: Border.all(color: index == activeAddress ? Colors.green : Colors.grey.withOpacity(0.1), width: 2)
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.white,
                                      child: index == activeAddress
                                          ? Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20,
                                      )
                                          : Icon(
                                        Icons.circle_outlined,
                                        color: Colors.grey.withOpacity(0.1),
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            addresses[index]["title"],
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                fontFamily: 'Beheshti',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18,
                                                color: Colors.black
                                            )
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          width: MediaQuery.of(context).size.width / 1.4,
                                          child: Text(
                                              addresses[index]["address"],
                                              style: TextStyle(
                                                  fontFamily: 'Beheshti',
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 15,
                                                  color: Colors.grey
                                              )
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                            ),
                          );
                        }
                        ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Fluttertoast.showToast(
                          msg: "خرید شما با موفقیت تکمیل شد",
                          toastLength: Toast.LENGTH_LONG,
                          timeInSecForIosWeb: 1,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
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
                                "تکمیل خرید",
                                style: TextStyle(fontFamily: 'Beheshti', fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Icon(Icons.done),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "سبد خرید",
            style: TextStyle(
                fontFamily: 'Beheshti',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black
            )
        ),
        toolbarHeight: 70,
        centerTitle: true,
        leadingWidth: 10,
        backgroundColor: Colors.white.withOpacity(0.3),
        elevation: 0,
      ),
      body: Stack(
        children: [
          items.isEmpty ? emptyCart() : (products.isNotEmpty ? Padding(padding: EdgeInsets.only(bottom: 100),child: filledCart(),) : Container()),
          items.isEmpty ? Container() : Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: finializePurchase(),
            ),
          )
        ],
      )
    );
  }
}
