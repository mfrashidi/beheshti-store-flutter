import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:beheshti_store/screens/addresses_screen.dart';
import 'package:beheshti_store/screens/edit_profile_screen.dart';
import 'package:beheshti_store/screens/favorites_screen.dart';
import 'package:beheshti_store/screens/login_screen.dart';
import 'package:beheshti_store/screens/my_products.dart';
import 'package:beheshti_store/screens/orders_screen.dart';
import 'package:beheshti_store/utils/converter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'category_screen.dart';


Map<String, dynamic> user = {};
int productsCount = 0;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {

  Future<void> _getUser() async {
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_ME\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        final data = await json.decode(utf8.decode(response));
        data["profile_picture"] = await _getImage(data["profile_picture"]);
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

  Future<void> _getMyProducts() async {
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_MY_PRODUCTS\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        final data = await json.decode(utf8.decode(response));
        setState(() {
          productsCount = data.length;
        });
      });
    });
  }

  Future<String> _changeImage() async {
    Completer<String> _completer = Completer<String>();
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";CHANGE_PROFILE_IMAGE=" + base64Encode(_image?.readAsBytesSync() as List<int>) + "\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        if (utf8.decode(response).length == 10) {
          Fluttertoast.showToast(
            msg: "عکس پروفایل با موفقیت عوض شد",
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 1,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          setState(() {
            user["profile_picture"] = base64Encode(_image?.readAsBytesSync() as List<int>);
          });
        }
      });
    });
    return _completer.future;
  }

  File? _image;
  final _picker = ImagePicker();
  Future<void> _openImagePicker() async {
    final XFile? pickedImage =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
      await _changeImage();
    }
  }

  @override
  void initState() {
    super.initState();
    user = {};
    productsCount = 0;

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _getUser();
      await _getMyProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimationLimiter(
        child: Container(
          child: Body(),
          padding: EdgeInsets.symmetric(horizontal: 25),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0),
        toolbarHeight: 210,
        flexibleSpace: Padding(
          padding: EdgeInsets.only(top: 65),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1))],
                        ),
                        child: user.isNotEmpty && user["profile_picture"].length > 1000 ? CircleAvatar(
                          backgroundImage: MemoryImage(Uint8List.fromList(base64Decode(user["profile_picture"]))),
                          radius: 50,
                        ) : CircularProgressIndicator(color: Colors.grey.shade300,),
                      ),
                      onTap: () {
                        _openImagePicker();
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: user.isNotEmpty ? Text(
                          user["name"] + " " + user["last_name"],
                          style: TextStyle(
                              fontFamily: 'Beheshti',
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.black
                          )
                      ) : SizedBox(
                        width: 100.0,
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
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: user.isNotEmpty ? Text(
                          englishToPersian(user["phone"]),
                          style: TextStyle(
                              fontFamily: 'Beheshti',
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.5)
                          )
                      ) : SizedBox(
                        width: 70.0,
                        height: 15.0,
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
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 30, top: 40),
                child:
                    GestureDetector(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('token');
                        Navigator.of(context, rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => new LoginScreen()));
                      },
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Icon(LineIcons.doorOpen),
                      ),
                    )
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  Widget _boxWidget(String text, String number, String logo) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, 7), // changes position of shadow
            ),
          ],
        ),
        child:
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 15, left: 10),
              child: Image.asset(logo, width: 40),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    text,
                    style: TextStyle(fontFamily: 'Beheshti', fontWeight: FontWeight.normal, fontSize: 15)
                ),
                Text(
                    number,
                    style: TextStyle(fontFamily: 'Beheshti', fontWeight: FontWeight.bold, fontSize: 15)
                )
              ],
            )
          ],
        )
    );
  }

  Widget _settingsWidget(String text, String logo) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, 7), // changes position of shadow
            ),
          ],
        ),
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(15),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                  text,
                  style: TextStyle(
                      fontFamily: 'Beheshti',
                      fontWeight: FontWeight.normal,
                      fontSize: 17,
                      color: Colors.black
                  )
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                logo,
                width: 25,
              ),
            )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> statistics = [
      {"logo": "assets/screens/profile/item.png",
        "text": "کالاهای من",
        "number": englishToPersian(productsCount.toString())
      },
      {"logo": "assets/screens/profile/basket.png",
        "text": "سفارش ها",
        "number": user.isNotEmpty ? englishToPersian((user["orders"] as List).length.toString()) : "۰"
      },
    ];
    List<Map<String, dynamic>> settings = [
      {"logo": "assets/screens/profile/user.png",
        "text": "پروفایل کاربری",
      },
      {"logo": "assets/screens/profile/heart.png",
        "text": "علاقه‌مندی ها",
      },
      {"logo": "assets/screens/profile/comment.png",
        "text": "نظرات",
      },
      {"logo": "assets/screens/profile/address.png",
        "text": "آدرس ها",
      },
    ];
    List<StatefulWidget> settingsScreen = [
      EditProfileScreen(),
      FavoritesScreen(),
      FavoritesScreen(),
      AddressesScreen(),
    ];
    return ListView(
      physics: BouncingScrollPhysics(),
      children: [
        GridView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 30),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2,
            crossAxisSpacing: 30,
            mainAxisSpacing: 30,
          ),
          children: [
            GestureDetector(
              child: _boxWidget(statistics[0]["text"], statistics[0]["number"], statistics[0]["logo"]),
              onTap: () {
                Navigator.of(context).push(CupertinoPageRoute(builder: (context) => MyProductScreen()));
              },
            ),
            GestureDetector(
              child: _boxWidget(statistics[1]["text"], statistics[1]["number"], statistics[1]["logo"]),
              onTap: () {
                Navigator.of(context).push(CupertinoPageRoute(builder: (context) => OrdersScreen()));
              },
            )
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemCount: settings.length,
          itemBuilder: (BuildContext context, int index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: -50.0,
                child: FadeInAnimation(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(CupertinoPageRoute(builder: (context) => settingsScreen[index]));
                    },
                    child: _settingsWidget(settings[index]["text"], settings[index]["logo"]),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}