import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final Function callback;

  const HomeScreen(this.callback);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Image.asset('assets/Beheshti.png', width: 150.0),
        toolbarHeight: 100,
        centerTitle: true,
        leadingWidth: 10,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () => callback(),
          child: Text('Go to Page3'),
        ),
      ),
    );
  }
}