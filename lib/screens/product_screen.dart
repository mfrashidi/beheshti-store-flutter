import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';

String productId = "";
Map<String, dynamic> product = {};
List images = [];
IconData heart = LineIcons.heart;
int colorIndex = 0;
int sizeIndex = 0;



class ProductScreen extends StatefulWidget {
  ProductScreen(String id) {
    productId = id;
  }

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  Future<void> _getProducts() async {
    final String response = await rootBundle.loadString('assets/products.json');
    final data = await json.decode(response);
    images = [];
    setState(() {
      product = data[productId];
      for (int i = 1; i < product["images_count"] + 1; i++) {
        images.add("assets/products/$productId-$i.jpeg");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    colorIndex = 0;
    sizeIndex = 0;
    heart = LineIcons.heart;
    _getProducts();
  }

  Widget _productImage() {
    final CarouselController _controller = CarouselController();
    return CarouselSlider(
      options: CarouselOptions(
        height: MediaQuery.of(context).size.width,
        autoPlayInterval: Duration(seconds: 5),
        autoPlay: true,
        viewportFraction: 1,
      ),
      carouselController: _controller,
      items: images.map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Image.asset(i);
          },
        );
      }).toList(),
    );
  }

  Widget _description() {
    Map<String, dynamic> description = product["description"];
    List<String> keys = [];
    for (var key in description.keys) {
      keys.add(key);
    }
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: keys.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
              verticalOffset: -25.0,
              child: FadeInAnimation(
                child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                        keys[index],
                        style: TextStyle(
                            fontFamily: 'Beheshti',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black
                        )
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        description[keys[index]],
                        style: TextStyle(
                            fontFamily: 'Beheshti',
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.5)
                        )
                    ),
                  ),
                  SizedBox(height: 30)
                ],
              )
            )
              )
            );
          }
      ),
    );
  }

  Widget _colorWidget(Color color, {bool isSelected = false}) {
    return CircleAvatar(
      radius: 12,
      backgroundColor: color.withAlpha(150),
      child: isSelected
          ? Icon(
        Icons.check_circle,
        color: color,
        size: 18,
      )
          : CircleAvatar(radius: 7, backgroundColor: color == Color(0xffffffff) ? Colors.grey : color),
    );
  }

  Widget _sizeWidget(String size, {bool isSelected = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: isSelected ?
          product["has_color"] ? Color(int.parse(product["colors"][colorIndex]["code"])) : Colors.lightBlueAccent
              : Colors.grey.withOpacity(0.5), spreadRadius: 1.5),
        ],
      ),
      child: Text(
          size,
          style: TextStyle(
              fontFamily: 'Beheshti',
              fontWeight: FontWeight.normal,
              fontSize: 12,
              color: Colors.black
          )
      ),
    );
  }


  Widget _availableColor() {
    List colors = product["colors"];
    List<Widget> colorWidgets = [];
    for (int i = 0; i < colors.length; i++) {
      colorWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              colorIndex = i;
            });
          },
          child: _colorWidget(Color(int.parse(colors[i]["code"])), isSelected: i == colorIndex ? true : false),
        )
      );
      if (i != colors.length - 1) {
        colorWidgets.add(SizedBox(width: 15));
      }
    }

    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                  "رنگ:",
                  style: TextStyle(
                      fontFamily: 'Beheshti',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black
                  )
              ),
              SizedBox(width: 5),
              Text(
                  colors[colorIndex]["name"],
                  style: TextStyle(
                      fontFamily: 'Beheshti',
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                      color: int.parse(colors[colorIndex]["code"]) != 0xffffff ? Color(int.parse(colors[colorIndex]["code"])) : Colors.grey
                  )
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: colorWidgets,
          ),
        )
      ],
    );
  }

  Widget _availableSize() {
    List sizes = product["sizes"];
    List<Widget> sizeWidgets = [];
    for (int i = 0; i < sizes.length; i++) {
      sizeWidgets.add(
          GestureDetector(
            onTap: () {
              setState(() {
                sizeIndex = i;
              });
            },
            child: _sizeWidget(sizes[i], isSelected: i == sizeIndex ? true : false),
          )
      );
      if (i != sizes.length - 1) {
        sizeWidgets.add(SizedBox(width: 15));
      }
    }

    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.centerRight,
          child: Text(
              "سایز",
              style: TextStyle(
                  fontFamily: 'Beheshti',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black
              )
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: sizeWidgets,
          ),
        )
      ],
    );
  }

  Widget _buyButton() {
    return Padding(
      padding: EdgeInsets.only(bottom: 35),
      child: ElevatedButton(
        onPressed: () {
          Fluttertoast.showToast(
            msg: "محصول به سبدخرید شما اضافه شد",
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 1,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        },
        style: ElevatedButton.styleFrom(
            primary: Color(0xffE6123D),
            shadowColor: Colors.black.withOpacity(0.5),
            fixedSize: Size(200, 50),
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(100),
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
                      "افزودن به سبد",
                      style: TextStyle(fontFamily: 'Beheshti', fontWeight: FontWeight.bold, fontSize: 17),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.add_shopping_cart),
                  )
                ],
              ),
            ),
      ),
    );
  }

  List<Widget> getStars(int star) {
    List<Widget> stars = [];
    for (int i = 5 - star; i > 0; i--) {
      stars.add(
          Icon(Icons.star_border, size: 17)
      );
    }
    for (int i = 0; i < star; i++) {
      stars.add(
          Icon(Icons.star,
              color: Color(0xFFF1EE52), size: 17)
      );
    }
    return stars;
  }

  Widget _detailWidget() {
    return DraggableScrollableSheet(
      maxChildSize: .75,
      initialChildSize: .53,
      minChildSize: .53,
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
                  SizedBox(height: 20),
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                                product["category"],
                                style: TextStyle(
                                    fontFamily: 'Beheshti',
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    color: Colors.lightBlue
                                )
                            ),
                            SizedBox(width: 5),
                            Text(
                                ">",
                                style: TextStyle(
                                    fontFamily: 'Beheshti',
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    color: Colors.lightBlue.withOpacity(0.5)
                                )
                            ),
                            SizedBox(width: 5),
                            Text(
                                product["sub_category"],
                                style: TextStyle(
                                    fontFamily: 'Beheshti',
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    color: Colors.lightBlue
                                )
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                                product["seller"],
                                style: TextStyle(
                                    fontFamily: 'Beheshti',
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    color: Color(0xFF016FA0)
                                )
                            ),
                            SizedBox(width: 5),
                            Icon(LineIcons.user, size: 15, color: Color(0xFF016FA0)
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          constraints: BoxConstraints(maxWidth: 200),
                          child: Text(
                              product["name"],
                              style: TextStyle(
                                  fontFamily: 'Beheshti',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                  color: Colors.black
                              )
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                    product["price"],
                                    style: TextStyle(
                                        fontFamily: 'Beheshti',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 22,
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
                            Row(
                              children: getStars(product["star"]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  product["has_color"] ? _availableColor() : Container(),
                  product["has_color"] && product["has_size"] ? SizedBox(
                    height: 15,
                  ) : Container(),
                  product["has_size"] ? _availableSize() : Container(),
                  product["has_color"] || product["has_size"] ? SizedBox(
                    height: 30,
                  ) : Container(),
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            "مشخصات",
                            style: TextStyle(
                                fontFamily: 'Beheshti',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black
                            )
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(CupertinoIcons.list_bullet, size: 25),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  _description()
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  FloatingActionButton _flotingButton() {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: Colors.indigoAccent,
      child: Icon(Icons.shopping_basket,
          color: Theme.of(context).floatingActionButtonTheme.backgroundColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 120,
          leading: Container(),
          flexibleSpace: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.arrow_back, color: Colors.black, size:25),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(100))
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (heart == LineIcons.heart) {
                          heart = LineIcons.heartAlt;
                          Fluttertoast.showToast(
                            msg: "محصول به علاقه‌مندی‌های شما اضافه شد",
                            toastLength: Toast.LENGTH_LONG,
                            timeInSecForIosWeb: 1,
                            gravity: ToastGravity.CENTER,
                            backgroundColor: Colors.redAccent,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        } else {
                          heart = LineIcons.heart;
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
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Icon(heart, color: Colors.redAccent, size:25),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(100))
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          backgroundColor: Colors.white.withOpacity(0),
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    _productImage(),
                  ],
                ),
                Container(
                  transform: Matrix4.translationValues(0.0, -50.0, 0.0),
                  child: _detailWidget(),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _buyButton(),
                )
              ],
            ),
    );
  }
}