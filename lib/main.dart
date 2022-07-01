import 'dart:async';
import 'dart:io';

import 'package:custom_navigator/custom_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nama_kala/screens/cart_screen.dart';
import 'package:nama_kala/screens/categories_screen.dart';
import 'package:nama_kala/screens/login_screen.dart';
import 'package:nama_kala/screens/profile_screen.dart';
import 'screens/home_screen.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((instance) {
    bool _isLoggedIn = (instance.getString('token') ?? "empty") != "empty";
    runApp(MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Directionality(textDirection: TextDirection.rtl, child: child!);
        },
        title: 'Beheshti Store',
        theme: ThemeData(
            primaryColor: Colors.grey[800],
            scaffoldBackgroundColor: Colors.white
        ),
        home: _isLoggedIn ? HomePage() : LoginScreen()));
  });
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  int activeIndex = 0;

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
    Color _activeIconColor = Colors.black;
    Color _iconBackgroundColor = Colors.white.withOpacity(0);

    final _items = [
      BottomNavigationBarItem(icon: Icon(LineIcons.store, color: activeIndex == 0 ? _activeIconColor : _inactiveIconColor, size: _iconSize), label: 'خانه'),
      BottomNavigationBarItem(icon: Icon(LineIcons.compass, color: activeIndex == 1 ? _activeIconColor : _inactiveIconColor, size: _iconSize), label: 'دسته‌بندی ها'),
      BottomNavigationBarItem(icon: Icon(LineIcons.shoppingCart, color: activeIndex == 2 ? _activeIconColor : _inactiveIconColor, size: _iconSize), label: 'سبد خرید'),
      BottomNavigationBarItem(icon: Icon(LineIcons.user, color: activeIndex == 3 ? _activeIconColor : _inactiveIconColor, size: _iconSize), label: 'پروفایل'),
    ];

    return CustomScaffold(
      scaffold: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Colors.white,
          items: _items,
        ),
      ),
      children: pages,
      onItemTap: (index) {
        setState(() {
          activeIndex = index;
        });
      },
    );
  }
}