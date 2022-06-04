import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfileScreen> {
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
                  Fluttertoast.showToast(
                    msg: "تغییرات شما با موفقیت ثبت شد",
                    toastLength: Toast.LENGTH_LONG,
                    timeInSecForIosWeb: 1,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
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
          TextField (
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
          TextField (
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
          TextField (
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
          TextField (
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