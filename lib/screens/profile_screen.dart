import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("پروفایل کاربری"),
          titleTextStyle: GoogleFonts.notoSansArabic(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          toolbarHeight: 100,
          centerTitle: true,
          leadingWidth: 10,
          backgroundColor: Colors.white.withOpacity(0.3),
          elevation: 0,
          leading: Transform.translate(
            offset: Offset(-20, 0),
            child: Icon(Icons.settings, color: Colors.black),
          )
      ),
      body: Center(child: Text('Page4')),
    );
  }
}