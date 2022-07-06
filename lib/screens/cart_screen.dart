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

List<String> items = [];
Map<String, dynamic> user = {};
List<Map<String, dynamic>> products = [];
int activeAddress = 0;

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  Future<void> _getProducts() async {
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_CART\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        List<dynamic> data = await json.decode(utf8.decode(response));
        setState(() {
          for (var p in data) {
            items.add(p.toString());
          }
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

  Future<void> _getUser() async {
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_ME\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        final data = await json.decode(utf8.decode(response));
        setState(() {
          user = data;
          activeAddress = user["active_address"];
        });
      });
    });
  }

  Future<void> _removeProduct(String productPattern) async {
    List<String> datas = productPattern.split("@");
    String productID = datas[0];
    int colorIndex = int.parse(datas[2]);
    int sizeIndex = int.parse(datas[3]);
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";REMOVE_FROM_CART=" + productID + "@1@" +
          colorIndex.toString() + "@" + sizeIndex.toString() + "\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        String result = utf8.decode(response);
        if (result == "DONE") {
          setState(() {
            Fluttertoast.showToast(
              msg: "محصول از سبد خریدتان حذف شد",
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
    });
  }

  Future<void> _addMore(String productPattern) async {
    List<String> datas = productPattern.split("@");
    String productID = datas[0];
    int colorIndex = int.parse(datas[2]);
    int sizeIndex = int.parse(datas[3]);
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";ADD_TO_CART=" + productID + "@1@" +
          colorIndex.toString() + "@" + sizeIndex.toString() + "\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        if (utf8.decode(response) == "DONE") {
          setState(() {
            print("Add one more of " + productID);
          });
        }
      });
    });
  }

  Future<void> _removeOnce(String productPattern) async {
    List<String> datas = productPattern.split("@");
    String productID = datas[0];
    int colorIndex = int.parse(datas[2]);
    int sizeIndex = int.parse(datas[3]);
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";REMOVE_FROM_CART_ONCE=" + productID + "@1@" +
          colorIndex.toString() + "@" + sizeIndex.toString() + "\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        if (utf8.decode(response) == "DONE") {
          setState(() {
            print(productID + " removed once");
          });
        }
      });
    });
  }

  Future<void> _finializePurchase() async {
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";FINALIZE_PURCHASE=" + activeAddress.toString() + "\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        if (utf8.decode(response) == "DONE") {
          Fluttertoast.showToast(
            msg: "خرید شما با موفقیت تکمیل شد",
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 1,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          setState(() {
            items = [];
          });
        } else {
          Fluttertoast.showToast(
            msg: "یک یا چند قلم از کالاها ناموجود می‌باشد",
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 1,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      });
    });
  }

  Future<Map<String, dynamic>> getProduct(String productId) async {
    print("here");
    Completer<Map<String, dynamic>> _completer = Completer<Map<String, dynamic>>();
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      print(token);
      serverSocket.write("AUTH=" + token + ";GET_PRODUCT=" + productId + "\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        Map<String, dynamic> data = json.decode(utf8.decode(response));
        data["image"] = await _getImage(data["image"]);
        print(data);
        _completer.complete(data);
      });
    });

    return _completer.future;
  }

  Future<int> getCartPrice() async {
    Completer<int> _completer = Completer<int>();
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_CART_PRICE\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        _completer.complete(int.parse(utf8.decode(response)));
      });
    });

    return _completer.future;
  }

  @override
  void initState() {
    super.initState();
    items = [];
    user = {};
    products = [];
    activeAddress = 0;

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _getProducts();
      await _getUser();
    });
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
          Widget list = AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: -50.0,
                child: FadeInAnimation(
                    child: FutureBuilder<Map<String, dynamic>>(
                        future: getProduct(items[index].split("@")[0]),
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
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 30,
                                mainAxisSpacing: 30,
                              ),
                              children: [
                                product.hasData && (product.data!["image"] as String).length > 1000 ? GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(CupertinoPageRoute(builder: (context) => ProductScreen(items[index].split("@")[0])));
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
                                    product.hasData ? Align(
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
                                                backgroundColor: Color(int.parse(product.data!["colors"][int.parse(items[index].split("@")[2])]["code"])).withAlpha(150),
                                                child: CircleAvatar(radius: 5, backgroundColor: Color(int.parse(product.data!["colors"][int.parse(items[index].split("@")[2])]["code"])) == Color(0xffffffff) ? Colors.grey : Color(int.parse(product.data!["colors"][int.parse(items[index].split("@")[2])]["code"]))),
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                  product.data!["colors"][int.parse(items[index].split("@")[2])]["name"],
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
                                                  product.data!["sizes"][int.parse(items[index].split("@")[3])].toString(),
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
                                                alignment: Alignment.centerRight,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _removeProduct(items[index]);
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
                                                        _addMore(items[index]);
                                                        List<String> datas = items[index].split("@");
                                                        datas[1] = (int.parse(datas[1]) + 1).toString();
                                                        items[index] = datas.join("@");
                                                      });
                                                    },
                                                    child: Icon(Icons.add),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                      persianize(items[index].split("@")[1]),
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
                                                        if (int.parse(items[index].split("@")[1]) > 1) {
                                                          setState(() {
                                                            _removeOnce(items[index]);
                                                            List<String> datas = items[index].split("@");
                                                            datas[1] = (int.parse(datas[1]) - 1).toString();
                                                            items[index] = datas.join("@");
                                                          });
                                                        }
                                                      },
                                                      child: Icon(Icons.remove, color: int.parse(items[index].split("@")[1]) == 1 ? Colors.grey.shade400 : Colors.black),
                                                    )
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ) : Stack(
                                      children: [
                                        SizedBox(
                                          width: 1000.0,
                                          height: 75.0,
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
                                        SizedBox(height: 40),
                                        Align(
                                              alignment: Alignment.bottomCenter,
                                              child: SizedBox(
                                                width: 1000.0,
                                                height: 50.0,
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
                                    )
                                  ],
                                )
                              ],
                            ),
                          );
                        }
                    )
          ),
                ),
          );
          return list;
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
                              FutureBuilder<int>(
                                  future: getCartPrice(),
                                  builder: (context, AsyncSnapshot<int> price) {
                                    if (price.hasData) {
                                      return Text(persianNumber(price.data!),
                                          style: TextStyle(
                                              fontFamily: 'Beheshti',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                              color: Colors.black
                                          )
                                      );
                                    } else {
                                      return SizedBox(
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
                                      );
                                    }
                                  }
                              ),
                              SizedBox(width: 5),
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
                    user.isNotEmpty ? ListView.separated(
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
                        ) : Container(),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _finializePurchase();
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
          items.isEmpty ? emptyCart() : Padding(padding: EdgeInsets.only(bottom: 100), child: filledCart()),
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
