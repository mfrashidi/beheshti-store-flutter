import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartScreen extends StatelessWidget {
  const CartScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("سبد خرید"),
        titleTextStyle: GoogleFonts.notoSansArabic(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
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