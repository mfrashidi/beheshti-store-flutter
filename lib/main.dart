import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(MaterialApp(
    builder: (context, child) {
      return Directionality(textDirection: TextDirection.rtl, child: child!);
    },
    title: 'Beheshti Store',
    theme: ThemeData(
      primaryColor: Colors.grey[800],
    ),
    home: Home()));
