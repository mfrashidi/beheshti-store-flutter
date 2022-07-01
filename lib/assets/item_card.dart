import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../screens/category_screen.dart';
import '../utils/converter.dart';

Future<int> _getImageLength(String imageID) async {
  Completer<int> _completer = Completer<int>();
  await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
    String token = await getToken() ?? "nothing";
    serverSocket.write("AUTH=" + token + ";GET_IMAGE_LENGTH=" + imageID + "\n");
    serverSocket.flush();
    serverSocket.listen((response) async {
      _completer.complete(int.parse(String.fromCharCodes(response)));
    });
  });
  return _completer.future;
}

Future<String> _getImage(String imageID) async {
  Completer<String> _completer = Completer<String>();
  String result = "";
  int length = await _getImageLength(imageID);
  await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
    String token = await getToken() ?? "nothing";
    serverSocket.write("AUTH=" + token + ";GET_IMAGE=" + imageID + "\n");
    serverSocket.flush();
    serverSocket.listen((response) async {
      result += await String.fromCharCodes(response);
      if (result.length >= length) {
        _completer.complete(result);
      }
    });
  });
  return _completer.future;
}

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
            FutureBuilder<String>(
                future: _getImage(img),
                builder: (context, AsyncSnapshot<String> image) {
                  if (image.hasData) {
                    return Image.memory(Uint8List.fromList(base64Decode(image.data!)), height: 120);
                  } else {
                    return SizedBox(
                      width: 120.0,
                      height: 120.0,
                      child: Shimmer.fromColors(
                          baseColor: Colors.white,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            width: 500.0,
                            height: 500.0,
                            color: Colors.white,
                          )
                      ),
                    );
                  }
                }
            ),
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
                    persianNumber(price),
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