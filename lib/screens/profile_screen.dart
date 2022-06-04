import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nama_kala/screens/my_products.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen();

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
          padding: EdgeInsets.only(top: 75),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1))],
                      ),
                      child: CircleAvatar(
                        backgroundImage: AssetImage('assets/screens/profile/profile.png'),
                        radius: 50,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 15),
                      child:
                      Text(
                          "فواد رشیدی",
                          style: TextStyle(
                              fontFamily: 'Beheshti',
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.black
                          )
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child:
                      Text(
                          "۰۹۱۲۵۴۷۸۳۶۷",
                          style: TextStyle(
                              fontFamily: 'Beheshti',
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.5)
                          )
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 30, top: 40),
                child:
                  Align(
                    alignment: Alignment.topLeft,
                    child: Icon(LineIcons.doorOpen),
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

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> statistics = [
      {"logo": "assets/screens/profile/item.png",
        "text": "کالاهای من",
        "number": "۶"
      },
      {"logo": "assets/screens/profile/basket.png",
        "text": "سفارش ها",
        "number": "۱۴"
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
              _boxWidget(statistics[1]["text"], statistics[1]["number"], statistics[1]["logo"]),
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
                  child: Container(
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
                                settings[index]["text"],
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
                              settings[index]["logo"],
                              width: 25,
                            ),
                          )
                        ],
                      )
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