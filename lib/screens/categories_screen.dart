import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'category_screen.dart';

List<Map<String, dynamic>> categories = [];
List<String> categoryNames = [];

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {

  ShaderMask fadeImage(String path) {
    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.transparent],
        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height - 10));
      },
      blendMode: BlendMode.dstIn,
      child: Image.asset(
        path,
        height: 400,
        fit: BoxFit.contain,
      ),
    );
  }

  Future<void> _getCategories() async {
    final String response = await rootBundle.loadString(
        'assets/categories.json');
    final data = await json.decode(response);
    setState(() {
      Map<String, dynamic> categoriesMap = data;
      categoriesMap.forEach((key, value) {
        categoryNames.add(key);
        categories.add(value);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    if (categories.isEmpty) _getCategories();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        body: AnimationLimiter(
          child: categories.isEmpty ? Container() : Container(
            child: GridView.builder(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.95,
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: -50.0,
                    child: FadeInAnimation(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(CupertinoPageRoute(builder: (context) => CategoryScreen(categoryNames[index])));
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(int.parse(categories[index]["color"])),
                                  Colors.white.withOpacity(0.25),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(.1),
                                )
                              ],
                            ),
                            child:
                            Stack(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: categories[index]["image_padding"]),
                                    child: categories[index]["has_fade_image"] ? fadeImage(categories[index]["image"]) : Image.asset(categories[index]["image"], width: categories[index]["image_width"]),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                      padding: const EdgeInsets.only(bottom: 20),
                                      child: Text(
                                          categories[index]["name"],
                                          style: TextStyle(fontFamily: 'Beheshti', fontWeight: FontWeight.bold, fontSize: 15)
                                      )
                                  ),
                                )
                              ],
                            )
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            padding: EdgeInsets.symmetric(horizontal: 25),
          ),
        ),
        appBar: AppBar(
            title: Text(
                "دسته بندی کالاها",
                style: TextStyle(
                    fontFamily: 'Beheshti',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black
                )
            ),
            toolbarHeight: 100,
            centerTitle: true,
            leadingWidth: 10,
            backgroundColor: Colors.white.withOpacity(0.3),
            elevation: 0
        )
    );
  }
}

  