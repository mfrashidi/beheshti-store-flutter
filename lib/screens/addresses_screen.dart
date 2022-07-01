import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';

import '../utils/converter.dart';
import 'category_screen.dart';

Map<String, dynamic> user = {};
int activeAddress = 0;
List addresses = [];

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({Key? key}) : super(key: key);
  @override
  _AddressesScreenState createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {

  Future<void> _getUser() async {
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_ME\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        final data = await json.decode(utf8.decode(response));
        setState(() {
          user = data;
          activeAddress = user["active_address"];
        });
      });
    });
  }

  Future<void> _setActiveAddress(int index) async {
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";SET_ACTIVE_ADDRESS=" + index.toString() + "\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        if (utf8.decode(response) == "DONE") {
          print("Active address changed");
        }
      });
    });
  }

  Future<void> _addAddress(String name, String location) async {
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";ADD_ADDRESS=" + unNormalize(name + "@ " + location) + "\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        if (utf8.decode(response) == "DONE") {
          print("Address added");
        }
      });
    });
  }

  Future<void> _removeAddress(int index) async {
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";REMOVE_ADDRESS=" + index.toString() + "\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        if (utf8.decode(response) == "DONE") {
          print("Address removed");
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void _showAddressDialog() {
    TextEditingController attController = new TextEditingController();
    TextEditingController desController = new TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                "اضافه کردن آدرس جدید",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Beheshti',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black
                )
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField (
                    controller: attController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      prefixStyle: TextStyle(
                          fontFamily: 'Beheshti',
                          fontWeight: FontWeight.normal,
                          fontSize: 17,
                          color: Colors.black
                      ),
                      labelStyle: TextStyle(
                          fontFamily: 'Beheshti',
                          fontWeight: FontWeight.normal,
                          fontSize: 17,
                          color: Colors.black
                      ),
                      labelText: 'نام',
                    ),
                  ),
                  SizedBox(height: 30),
                  TextField (
                    controller: desController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      prefixStyle: TextStyle(
                          fontFamily: 'Beheshti',
                          fontWeight: FontWeight.normal,
                          fontSize: 17,
                          color: Colors.black
                      ),
                      labelStyle: TextStyle(
                          fontFamily: 'Beheshti',
                          fontWeight: FontWeight.normal,
                          fontSize: 17,
                          color: Colors.black
                      ),
                      labelText: 'آدرس',
                    ),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text(
                    "افزودن",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Beheshti',
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                        color: Colors.white
                    )
                ),
                onPressed: () {
                  setState(() {
                    addresses.add({
                      "title": attController.text,
                      "address": desController.text
                    });
                    _addAddress(attController.text, desController.text);
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Widget _getAddressList() {
    addresses = user["addresses"];
    return user.isNotEmpty ? ListView.separated(
        separatorBuilder: (context, index) => SizedBox(
          height: 10,
        ),
        shrinkWrap: true,
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: (){
              setState(() {
                activeAddress = index;
                _setActiveAddress(activeAddress);
              });
            },
            child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: index == activeAddress ? Colors.green : Colors.grey.withOpacity(0.1), width: 2)
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.white,
                      child: index == activeAddress
                          ? Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      )
                          : Icon(
                        Icons.circle_outlined,
                        color: Colors.grey.withOpacity(0.1),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            addresses[index]["title"],
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontFamily: 'Beheshti',
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.black
                            )
                        ),
                        SizedBox(height: 5),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.5,
                          child: Text(
                              addresses[index]["address"],
                              style: TextStyle(
                                  fontFamily: 'Beheshti',
                                  fontWeight: FontWeight.normal,
                                  fontSize: 15,
                                  color: Colors.grey
                              )
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            addresses.removeAt(index);
                            _removeAddress(index);
                            activeAddress = 0;
                            _setActiveAddress(activeAddress);
                          });
                        },
                        child: Icon(LineIcons.trash, color: index == activeAddress ? Colors.green : Colors.grey.withOpacity(0.5),),
                      ),
                    )
                  ],
                )
            ),
          );
        }
    ) : CircularProgressIndicator(color: Colors.grey.shade300);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "آدرس ها",
            style: TextStyle(
                fontFamily: 'Beheshti',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black
            )
        ),
        toolbarHeight: 80,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white.withOpacity(0.3),
        elevation: 0,
        flexibleSpace: SafeArea(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: Icon(LineIcons.mapPin, size: 25),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            children: [
              Text(
                "با کلیک بر روی آدرس موردنظر، آن را آدرس پیش‌فرض خود کنید",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Beheshti',
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                    color: Colors.black
                ),
              ),
              SizedBox(height: 20),
              _getAddressList(),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  _showAddressDialog();
                },
                style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    shadowColor: Colors.black.withOpacity(0.5),
                    fixedSize: Size(double.infinity, 60),
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10),
                    )
                ),
                child:
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "اضافه کردن آدرس جدید",
                          style: TextStyle(fontFamily: 'Beheshti', fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.add),
                      )
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

}