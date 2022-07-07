import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:beheshti_store/utils/converter.dart';

import 'category_screen.dart';

Map<String, dynamic> user = {};

TextEditingController nameController = TextEditingController();
TextEditingController lastNameController = TextEditingController();
TextEditingController phoneController = TextEditingController();
TextEditingController emailController = TextEditingController();

final numberRegex = RegExp(r'^(\+98|0)9[0-9]{9}$');

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfileScreen> {

  Future<void> _getUser() async {
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_ME\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        final data = await json.decode(utf8.decode(response));
        setState(() {
          user = data;
          nameController.text = user["name"];
          lastNameController.text = user["last_name"];
          phoneController.text = user["phone"];
          emailController.text = user["email"];
        });
      });
    });
  }

  Future<void> _save() async {
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";CHANGE_PROFILE=" + unNormalize(nameController.text) + "|" + unNormalize(lastNameController.text) +
          "|" + phoneController.text + "|" + emailController.text + "\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        if (utf8.decode(response) == "DONE") {
          Fluttertoast.showToast(
            msg: "تغییرات شما با موفقیت ثبت شد",
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 1,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          Navigator.of(context).pop();
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _getUser();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "ویرایش پروفایل",
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
              child: GestureDetector(
                onTap: () {
                  if (!numberRegex.hasMatch(phoneController.text)) {
                    Fluttertoast.showToast(
                      msg: "شماره تماس قابل قبول نیست",
                      toastLength: Toast.LENGTH_LONG,
                      timeInSecForIosWeb: 1,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else {
                    _save();
                  }
                },
                child: Text(
                    "ذخیره",
                    style: TextStyle(
                        fontFamily: 'Beheshti',
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                        color: Colors.lightBlue
                    )
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        children: [
          TextFormField (
            controller: nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.green,
                  width: 10,
                ),
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
          TextFormField (
            controller: lastNameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.green,
                  width: 10,
                ),
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
              labelText: 'نام خانوادگی',
            ),
          ),
          SizedBox(height: 30),
          TextFormField (
            controller: phoneController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.green,
                  width: 10,
                ),
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
              labelText: 'شماره تماس',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
          ),
          SizedBox(height: 30),
          TextFormField (
            controller: emailController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.green,
                  width: 10,
                ),
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
              labelText: 'ایمیل',
            ),
          ),
        ],
      ),
    );
  }

}