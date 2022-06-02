import 'package:flutter/material.dart';
import '../customized_libs/search_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen()
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showLogo = true;
  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: AnimSearchBar(
                    width: MediaQuery.of(context).size.width - 40,
                    rtl: true,
                    helpText: "جستجو",
                    closeSearchOnSuffixTap: true,
                    autoFocus: true,
                    style: TextStyle(
                        fontFamily: 'Beheshti',
                        fontWeight: FontWeight.normal,
                        fontSize: 17,
                        color: Colors.black
                    ),
                    // autoFocus: true,
                    textController: textController,
                    onSuffixTap: () {
                      setState(() {
                        showLogo = false;
                      });
                      textController.clear();
                    },
                    onCloseBar: () {
                      setState(() {
                        showLogo = true;
                      });
                    }
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: AnimatedOpacity(
                  opacity: showLogo ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 100),
                  child: Image.asset('assets/Beheshti.png', width: 150.0),
                ),
              )
            ],
          ),
        ),
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Body(),
    );
  }
}
class Body extends StatelessWidget {
  var images = [
    "assets/screens/home/banner_1.jpeg",
    "assets/screens/home/banner_2.jpeg",
    "assets/screens/home/banner_3.jpeg",
    "assets/screens/home/banner_4.jpeg",
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      children: [
        CarouselSlider(
          options: CarouselOptions(
              height: 200.0,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              enlargeCenterPage: true,

          ),
          items: images.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              spreadRadius: -10.0,
                              blurRadius: 10.0,
                              offset: Offset(0.0, 10.0),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.asset(i, fit: BoxFit.cover),
                        ),
                    ),
                );
              },
            );
          }).toList(),
        )
      ],
    );
  }
}
