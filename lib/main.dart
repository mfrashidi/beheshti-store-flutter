import 'package:flutter/material.dart';
import 'package:nama_kala/screens/cart_screen.dart';
import 'package:nama_kala/screens/categories_screen.dart';
import 'package:nama_kala/screens/profile_screen.dart';
import 'screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

TextStyle appBarFont = GoogleFonts.notoSansArabic(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold);

void main() => runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    builder: (context, child) {
      return Directionality(textDirection: TextDirection.rtl, child: child!);
    },
    title: 'Beheshti Store',
    theme: ThemeData(
      primaryColor: Colors.grey[800],
      scaffoldBackgroundColor: Colors.white
    ),
    home: HomePage()));

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int activeIndex = 0;
  void changeActivePage(int index) {
    setState(() {
      activeIndex = index;
    });
  }

  List<Widget> pages = [];

  @override
  void initState() {
    pages = [
      HomeScreen(),
      CategoriesScreen(),
      CartScreen(),
      ProfileScreen()
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _iconSize = 30;
    MaterialColor _inactiveIconColor = Colors.grey;
    Color _iconBackgroundColor = Colors.white.withOpacity(0);
    return Scaffold(
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(.1),
              )
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
              child: GNav(
                rippleColor: Colors.grey[300]!,
                hoverColor: Colors.grey[100]!,
                gap: 8,
                activeColor: Colors.black,
                iconSize: 24,
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                duration: Duration(milliseconds: 300),
                tabBackgroundColor: Colors.grey[100]!,
                color: Colors.black,
                tabs: [
                  GButton(
                    icon: LineIcons.store,
                    iconSize: _iconSize,
                    iconColor: _inactiveIconColor,
                    backgroundColor: _iconBackgroundColor,
                  ),
                  GButton(
                    icon: LineIcons.compass,
                    iconSize: _iconSize,
                    iconColor: _inactiveIconColor,
                    backgroundColor: _iconBackgroundColor,
                  ),
                  GButton(
                    icon: LineIcons.shoppingCart,
                    iconSize: _iconSize,
                    iconColor: _inactiveIconColor,
                    backgroundColor: _iconBackgroundColor,
                  ),
                  GButton(
                    icon: LineIcons.user,
                    iconSize: _iconSize,
                    iconColor: _inactiveIconColor,
                    backgroundColor: _iconBackgroundColor,
                  ),
                ],
                selectedIndex: activeIndex,
                onTabChange: (index) {
                  changeActivePage(index);
                  })
              ),
            ),
          ),
      body: pages[activeIndex],
        );
  }
}