import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen();

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
        toolbarHeight: 100,
        centerTitle: true,
        leadingWidth: 10,
        backgroundColor: Colors.white.withOpacity(0.3),
        elevation: 0,
      ),
      body: Center(child: Text('Page3')),
    );
  }
}