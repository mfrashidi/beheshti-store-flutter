import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Container getItemCard(var img, var name, var price) {
  return Container(
    width: 165,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(5)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          spreadRadius: 0,
          blurRadius: 10,
          offset: Offset(0, 10), // changes position of shadow
        ),
      ],
    ),
    padding: EdgeInsets.all(10),
    child: Stack(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
            children: [
              new Image.asset(
                img,
                height: 120,),
              Text(
                  name,
                  style: TextStyle(
                      fontFamily: 'Beheshti',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.black
                  )
              ),
            ],
          ),
        ),
        Align(
            alignment: Alignment.bottomRight,
            child: Icon(CupertinoIcons.cart_badge_plus,
              size: 22,
              color: Color(0xFF207D4C),)
        ),
        Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              height: 20,
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: [
                  Text(
                      price,
                      style: TextStyle(
                          fontFamily: 'Beheshti',
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                          color: Colors.black
                      )
                  ),
                  Text(
                      "تومان",
                      style: TextStyle(
                          fontFamily: 'Beheshti',
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: Colors.black
                      )
                  ),
                ],
              ),
            )
        )
      ],
    ),
  );
}