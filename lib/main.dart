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

  static TextStyle _appBarFont = GoogleFonts.notoSansArabic(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold);

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
      titleTextStyle: _appBarFont,
      toolbarHeight: 100,
      centerTitle: true,
      leadingWidth: 10,
      backgroundColor: Colors.white,
      elevation: 0
    ),
    AppBar(
      title: Text("سبد خرید"),
      titleTextStyle: _appBarFont,
      toolbarHeight: 100,
      centerTitle: true,
      leadingWidth: 10,
      backgroundColor: Colors.white,
      elevation: 0,
    ),
    AppBar(
      title: Text("پروفایل کاربری"),
      titleTextStyle: _appBarFont,
      toolbarHeight: 100,
      centerTitle: true,
      leadingWidth: 10,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Transform.translate(
        offset: Offset(-20, 0),
        child: Icon(Icons.settings, color: Colors.black),
      )
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
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
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
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: Duration(milliseconds: 300),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.black,
              tabs: [
                GButton(
                  icon: LineIcons.home,
                  iconSize: 25,
                ),
                GButton(
                  icon: LineIcons.compass,
                  iconSize: 25,
                ),
                GButton(
                  icon: LineIcons.shoppingCart,
                  iconSize: 25,
                ),
                GButton(
                  icon: LineIcons.user,
                  iconSize: 25,
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
