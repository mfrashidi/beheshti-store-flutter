import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nama_kala/screens/category_screen.dart';
import 'package:nama_kala/screens/sub_category_products.dart';
import 'package:nama_kala/utils/converter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'add_new_product_screen.dart';

String productId = "";
Map<String, dynamic> product = {};
Map<String, dynamic> category = {};
Map<String, dynamic> user = {};
List images = [];
IconData heart = LineIcons.heart;
int colorIndex = 0;
int sizeIndex = 0;

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

Future<String?> getToken() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await _prefs;
  final String token = prefs.getString('token') ?? "empty";

  return token;
}

Future<String> getSellerName(String sellerID) async {
  Completer<String> _completer = Completer<String>();
  await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
    String token = await getToken() ?? "nothing";
    serverSocket.write("AUTH=" + token + ";GET_USER_NAME=" + sellerID + "\n");
    serverSocket.flush();
    serverSocket.listen((response) async {
      _completer.complete(utf8.decode(response));
    });
  });

  return _completer.future;
}

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

  Future<void> _getProduct() async {
    String result;
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_PRODUCT=" + productId + "\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        result = utf8.decode(response);
        final data = await json.decode(result);
        images = [];
        setState(() {
          product = data;
          for (int i = 1; i < product["images_count"] + 1; i++) {
            images.add("assets/products/$productId-$i.jpeg");
          }
        });
        product["image"] = await _getImage(product["image"]);
        _getCategory();
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

  Future<void> _getFavorites() async {
    List<String> favorites = [];
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_FAVORITES" + "\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        List<dynamic> data = json.decode(utf8.decode(response));
        for (var f in data) {
          favorites.add(f.toString());
        }
        setState(() {
          if (favorites.contains(productId)) {
            heart = LineIcons.heartAlt;
          } else {
            heart = LineIcons.heart;
          }
        });
      });
    });
  }

  Future<void> _addToCart() async {
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";ADD_TO_CART=" + product["product_id"] + "@1@" +
          (product["has_color"] ? colorIndex.toString() : "-1") + "@" + (product["has_size"] ? sizeIndex.toString() : "-1") + "\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        if (utf8.decode(response) == "DONE") {
          Fluttertoast.showToast(
            msg: "محصول به سبدخرید شما اضافه شد",
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 1,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      });
    });
  }

  Future<void> _getCategory() async {
    String result;

    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_CATEGORY=" + product["sub_category"].split("_")[0] + "\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        result = utf8.decode(response);
        final data = await json.decode(result);
        setState(() {
          category = data;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    colorIndex = 0;
    sizeIndex = 0;
    product = {};
    category = {};
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _getProduct();
      await _getUser();
      await _getFavorites();
    });
  }

  Widget _productImage() {
    final CarouselController _controller = CarouselController();
    return CarouselSlider(
      options: CarouselOptions(
        height: MediaQuery.of(context).size.width,
        autoPlayInterval: Duration(seconds: 5),
        viewportFraction: 1,
      ),
      carouselController: _controller,
      items: [product.isNotEmpty && (product["image"] as String).length > 1000 ? Image.memory(Uint8List.fromList(base64Decode(product["image"]))) : Container(
        child: Center(
          child: CircularProgressIndicator(color: Colors.grey.shade300),
        ),
      )],
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
            child: _sizeWidget(sizes[i].toString(), isSelected: i == sizeIndex ? true : false),
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
          _addToCart();
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

  Widget _outOfStockButton() {
    return Padding(
      padding: EdgeInsets.only(bottom: 35),
      child: ElevatedButton(
        onPressed: () {
          Fluttertoast.showToast(
            msg: "نداریم دیگه مهندس",
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 1,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        },
        style: ElevatedButton.styleFrom(
            primary: Color(0xffE6123D),
            shadowColor: Colors.black.withOpacity(0.5),
            fixedSize: Size(250, 50),
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
                alignment: Alignment.center,
                child: Text(
                  "کالا ناموجود می‌باشد  :(",
                  style: TextStyle(fontFamily: 'Beheshti', fontWeight: FontWeight.bold, fontSize: 17),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _editButton() {
    return Padding(
      padding: EdgeInsets.only(bottom: 35),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) => AddNewProductScreen(product)));
        },
        style: ElevatedButton.styleFrom(
            primary: Color(0xff179268),
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
                  "ویرایش محصول",
                  style: TextStyle(fontFamily: 'Beheshti', fontWeight: FontWeight.bold, fontSize: 17),
                  textAlign: TextAlign.center,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.edit),
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
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(CupertinoPageRoute(builder: (context) => CategoryScreen(product["sub_category"].toString().split("_")[0])));
                              },
                              child: category.isNotEmpty ? Text(
                                  category["name"],
                                  style: TextStyle(
                                      fontFamily: 'Beheshti',
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12,
                                      color: Colors.lightBlue
                                  )
                              ) : SizedBox(
                                width: 70,
                                height: 15,
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
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(CupertinoPageRoute(builder: (context) => SubCategoryScreen(product["sub_category"])));
                              },
                              child: category.isNotEmpty ? Text(
                                  category["sub_categories"][product["sub_category"].split("_")[1]]["name"],
                                style: TextStyle(
                                    fontFamily: 'Beheshti',
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    color: Colors.lightBlue
                                )
                            ) : SizedBox(
                                width: 70,
                                height: 15,
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
                            )
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
                            product.isNotEmpty ? Text(product["seller_name"],
                                style: TextStyle(
                                    fontFamily: 'Beheshti',
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    color: Color(0xFF016FA0)
                                )
                            ) : SizedBox(
                              width: 60.0,
                              height: 15.0,
                              child: Shimmer.fromColors(
                                  baseColor: Colors.grey.shade50,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                    width: 500.0,
                                    height: 500.0,
                                    color: Colors.white,
                                  )
                              ),
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
                          child: product.isNotEmpty ? Text(
                              product["name"],
                              style: TextStyle(
                                  fontFamily: 'Beheshti',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                  color: Colors.black
                              )
                          ) : SizedBox(
                            width: 200.0,
                            height: 75.0,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade50,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  width: 500.0,
                                  height: 500.0,
                                  color: Colors.white,
                                )
                            ),
                          ),
                        ),
                        product.isNotEmpty ? Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                    persianNumber(product["price"]),
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
                              children: product.isNotEmpty ? getStars(product["stars"]) : [],
                            ),
                          ],
                        ) : SizedBox(
                          width: 75.0,
                          height: 25,
                          child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade50,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                width: 500.0,
                                height: 500.0,
                                color: Colors.white,
                              )
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  product.isNotEmpty ? (product["has_color"] ? _availableColor() : Container()) : Container(),
                  product.isNotEmpty ? (product["has_color"] && product["has_size"] ? SizedBox(
                    height: 15,
                  ) : Container()) : Container(),
                  product.isNotEmpty ? (product["has_size"] ? _availableSize() : Container()) : Container(),
                  product.isNotEmpty ? (product["has_color"] || product["has_size"] ? SizedBox(
                    height: 30,
                  ) : Container()) : Container(),
                  product.isNotEmpty ? Stack(
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
                  ) : SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
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
                  product.isNotEmpty ?SizedBox(
                    height: 15,
                  ) : Container(),
                  product.isNotEmpty ? _description() : Container()
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  FloatingActionButton _floatingButton() {
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
                    onTap: () async {
                      await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
                        String token = await getToken() ?? "nothing";
                        if (heart == LineIcons.heart) {
                          serverSocket.write("AUTH=" + token + ";ADD_FAVORITE=" + productId + "\n");
                          serverSocket.flush();
                          serverSocket.listen((response) async {
                            String result = utf8.decode(response);
                            if (result == "DONE") {
                              setState(() {
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
                              });
                            }
                          });
                        } else {
                          serverSocket.write("AUTH=" + token + ";REMOVE_FAVORITE=" + productId + "\n");
                          serverSocket.flush();
                          serverSocket.listen((response) async {
                            String result = utf8.decode(response);
                            if (result == "DONE") {
                              setState(() {
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
                              });
                            }
                          });
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
                  child: (user.isNotEmpty && product.isNotEmpty) ? (user["user_id"] == product["seller"] ? _editButton() : ((product["stock"] != 0) ? _buyButton() : _outOfStockButton())) : Container(),
                )
              ],
            ),
    );
  }
}