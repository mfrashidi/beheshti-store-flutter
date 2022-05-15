import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

void main() => runApp(MaterialApp(
    builder: (context, child) {
      return Directionality(textDirection: TextDirection.rtl, child: child!);
    },
    title: 'Beheshti Store',
    theme: ThemeData(
      primaryColor: Colors.grey[800],
    ),
    home: Home()));

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.w600);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'خانه',
      style: optionStyle,
    ),
    Text(
      'کاوش',
      style: optionStyle,
    ),
    Text(
      'سبد خرید',
      style: optionStyle,
    ),
    Text(
      'پروفایل',
      style: optionStyle,
    ),
  ];

  static List<AppBar> _appbars = <AppBar>[
    AppBar(
      title: new Image.asset('assets/Beheshti.png', width: 150.0),
      toolbarHeight: 100,
      centerTitle: true,
      leadingWidth: 10,
      backgroundColor: Colors.white,
      elevation: 0,
    ),
    AppBar(
        title: Text("تازه ها"),
        titleTextStyle: GoogleFonts.notoSansArabic(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      toolbarHeight: 100,
      centerTitle: true,
      leadingWidth: 10,
      backgroundColor: Colors.white,
      elevation: 0
    ),
    AppBar(
      title: Text("سبد خرید"),
      titleTextStyle: GoogleFonts.notoSansArabic(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      toolbarHeight: 100,
      centerTitle: true,
      leadingWidth: 10,
      backgroundColor: Colors.white,
      elevation: 0,
    ),
    AppBar(
      title: Text("پروفایل کاربری"),
      titleTextStyle: GoogleFonts.notoSansArabic(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      toolbarHeight: 100,
      centerTitle: true,
      leadingWidth: 10,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Icon(Icons.settings, color: Colors.black),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appbars.elementAt(_selectedIndex),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.all(Radius.circular(100)),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: Duration(milliseconds: 300),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.black,
              tabs: [
                GButton(
                  icon: LineIcons.home,
                ),
                GButton(
                  icon: LineIcons.compass,
                ),
                GButton(
                  icon: LineIcons.shoppingCart,
                ),
                GButton(
                  icon: LineIcons.user,
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
