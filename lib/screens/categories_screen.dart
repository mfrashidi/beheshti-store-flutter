import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: AnimationLimiter(
        child: Container(
          child: Body(),
          padding: EdgeInsets.symmetric(horizontal: 25),
        ),
      ),
      appBar: AppBar(
          title: Text("دسته بندی کالاها"),
          titleTextStyle: GoogleFonts.notoSansArabic(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          toolbarHeight: 100,
          centerTitle: true,
          leadingWidth: 10,
          backgroundColor: Colors.white.withOpacity(0.3),
          elevation: 0
      )
    );
  }
}


class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> categories = [
      {"pic": "assets/screens/categories/Macbook.png",
        "text": "دیجیتال",
        "color": Color(0x9CA2F0FF),
        "fade": false,
        "padding": 30.0,
        "width": 125.0
      },
      {"pic": "assets/screens/categories/clothing.png",
        "text": "پوشاک",
        "color": Color(0xFFFFA0A0),
        "fade": true,
        "padding": 10.0,
        "width": 100.0
      },
      {"pic": "assets/screens/categories/Books.png",
        "text": "کتاب و لوازم التحریر",
        "color": Color(0xA2F0FF9C),
        "fade": false,
        "padding": 20.0,
        "width": 100.0
      },
      {"pic": "assets/screens/categories/Tent.png",
        "text": "ورزش و سفر",
        "color": Color(0xA2A7FFC4),
        "fade": false,
        "padding": 5.0,
        "width": 100.0
      },
    ];
    return GridView.builder(
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
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        categories[index]["color"],
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
                          padding: EdgeInsets.only(top: categories[index]["padding"]),
                          child: categories[index]["fade"] ? fadeImage(categories[index]["pic"]) : Image.asset(categories[index]["pic"], width: categories[index]["width"]),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text(
                                categories[index]["text"],
                                style: TextStyle(fontFamily: 'Beheshti', fontWeight: FontWeight.bold, fontSize: 15)
                            )
                        ),
                      )
                    ],
                  )
              ),
            ),
          ),
        );
      },
    );
  }
}
  