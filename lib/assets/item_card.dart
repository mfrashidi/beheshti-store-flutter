import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Stack getItemCard(var img, var name, var price) {
  return Stack(
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
  );
}