import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:passwordfield/passwordfield.dart';

import '../main.dart';

bool tryToLogin = true;

TextEditingController nameController = TextEditingController();
TextEditingController familyNameController = TextEditingController();
TextEditingController phoneController = TextEditingController();
TextEditingController storeNameController = TextEditingController();
TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();

TextEditingController phoneSController = TextEditingController();
TextEditingController passwordSController = TextEditingController();



final numberRegex = RegExp(r'^(\+98|0)9[0-9]{9}$');
final passwordRegex = RegExp(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$");

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {

  @override
  void initState() {
    super.initState();
    tryToLogin = true;

    nameController = TextEditingController();
    familyNameController = TextEditingController();
    phoneController = TextEditingController();
    storeNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    phoneSController = TextEditingController();
    passwordSController = TextEditingController();
  }

  Widget _signUpButtons() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: ListView(
          shrinkWrap: true,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent,
                  shadowColor: Colors.black.withOpacity(0.5),
                  fixedSize: Size(double.infinity, 50),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5),
                  )
              ),
              child: const Text(
                  "ایجاد حساب کاربری",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Beheshti',
                      fontWeight: FontWeight.normal,
                      fontSize: 20,
                      color: Colors.white
                  )
              ),
              onPressed: () {
                String msg = "";
                bool isLoggedIn = false;
                if (nameController.text.isEmpty) {
                  msg = "فیلد نام اجباری است";
                } else if (familyNameController.text.isEmpty) {
                  msg = "فیلد نام خانوادگی اجباری است";
                } else if (phoneController.text.isEmpty) {
                  msg = "فیلد شماره تماس اجباری است";
                } else if (!numberRegex.hasMatch(phoneController.text)) {
                  msg = "شماره تماس اشتباه وارد شده است";
                } else if (passwordController.text.isEmpty) {
                  msg = "فیلد رمز عبور اجباری است";
                } else if (!passwordRegex.hasMatch(passwordController.text)) {
                  msg = "رمز عبور قابل قبول نیست";
                } else {
                  isLoggedIn = true;
                  Navigator.of(context).push(CupertinoPageRoute(builder: (context) => HomePage()));
                  Fluttertoast.showToast(
                    msg: "خوش آمدید",
                    toastLength: Toast.LENGTH_LONG,
                    timeInSecForIosWeb: 1,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
                if (!isLoggedIn) {
                  Fluttertoast.showToast(
                    msg: msg,
                    toastLength: Toast.LENGTH_LONG,
                    timeInSecForIosWeb: 1,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.redAccent,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  shadowColor: Colors.black.withOpacity(0.5),
                  fixedSize: Size(double.infinity, 50),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5),
                      side: BorderSide(color: Colors.blueAccent, width: 2)
                  )
              ),
              child: const Text(
                  "ورود",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Beheshti',
                      fontWeight: FontWeight.normal,
                      fontSize: 20,
                      color: Colors.blueAccent
                  )
              ),
              onPressed: () {
                setState(() {
                  tryToLogin = true;
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _loginButtons() {
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: ListView(
          shrinkWrap: true,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent,
                  shadowColor: Colors.black.withOpacity(0.5),
                  fixedSize: Size(double.infinity, 50),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5),
                  )
              ),
              child: const Text(
                  "ورود",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Beheshti',
                      fontWeight: FontWeight.normal,
                      fontSize: 20,
                      color: Colors.white
                  )
              ),
              onPressed: () {
                String msg = "";
                bool isLoggedIn = false;
                if (phoneSController.text.isEmpty) {
                  msg = "فیلد شماره تماس اجباری است";
                } else if (!numberRegex.hasMatch(phoneSController.text)) {
                  msg = "شماره تماس اشتباه وارد شده است";
                } else if (passwordSController.text.isEmpty) {
                  msg = "فیلد رمز عبور اجباری است";
                } else if (!passwordRegex.hasMatch(passwordSController.text)) {
                  msg = "رمز عبور قابل قبول نیست";
                } else {
                  isLoggedIn = true;
                  Navigator.of(context).push(CupertinoPageRoute(builder: (context) => HomePage()));
                  Fluttertoast.showToast(
                    msg: "خوش آمدید",
                    toastLength: Toast.LENGTH_LONG,
                    timeInSecForIosWeb: 1,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
                if (!isLoggedIn) {
                  Fluttertoast.showToast(
                    msg: msg,
                    toastLength: Toast.LENGTH_LONG,
                    timeInSecForIosWeb: 1,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.redAccent,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  shadowColor: Colors.black.withOpacity(0.5),
                  fixedSize: Size(double.infinity, 50),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5),
                      side: BorderSide(color: Colors.blueAccent, width: 2)
                  )
              ),
              child: const Text(
                  "ثبت نام",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Beheshti',
                      fontWeight: FontWeight.normal,
                      fontSize: 20,
                      color: Colors.blueAccent
                  )
              ),
              onPressed: () {
                setState(() {
                  tryToLogin = false;
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _signUpFields () {
    return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 50),
          child: Align(
            alignment: Alignment.topCenter,
            child: ListView(
              padding: EdgeInsets.all(30),
              shrinkWrap: true,
              children: [
                TextField (
                  controller: nameController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelStyle: TextStyle(
                        fontFamily: 'Beheshti',
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                        color: Colors.black
                    ),
                    labelText: 'نام',
                  ),
                ),
                TextField (
                  controller: familyNameController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelStyle: TextStyle(
                        fontFamily: 'Beheshti',
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                        color: Colors.black
                    ),
                    labelText: 'نام خانوادگی',
                  ),
                ),
                TextField (
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelStyle: TextStyle(
                        fontFamily: 'Beheshti',
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                        color: Colors.black
                    ),
                    labelText: 'شماره تماس',
                  ),
                ),
                TextField (
                  controller: storeNameController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelStyle: TextStyle(
                        fontFamily: 'Beheshti',
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                        color: Colors.black
                    ),
                    labelText: 'نام فروشگاه',
                  ),
                ),
                TextField (
                  controller: emailController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelStyle: TextStyle(
                        fontFamily: 'Beheshti',
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                        color: Colors.black
                    ),
                    labelText: 'ایمیل',
                  ),
                ),
                PasswordField(
                  controller: passwordController,
                  inputDecoration: PasswordDecoration(
                      inputStyle: TextStyle(
                          fontFamily: 'Beheshti',
                          fontWeight: FontWeight.normal,
                          fontSize: 17,
                          color: Colors.black
                      ),
                      hintStyle: TextStyle(
                          fontFamily: 'Beheshti',
                          fontWeight: FontWeight.normal,
                          fontSize: 20,
                          color: Colors.black
                      ),
                      errorStyle: TextStyle(
                          fontFamily: 'Beheshti',
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          color: Colors.redAccent
                      )
                  ),
                  hintText: 'رمز عبور',
                  passwordConstraint: r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$",
                  border: PasswordBorder(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue.shade100,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue.shade100,
                      ),
                    ),
                    focusedErrorBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  errorMessage:
                  'رمز عبور قابل قبول نیست',
                ),
              ],
            ),
          ),
        )
    );
  }

  Widget _loginFields () {
    return Align(
      alignment: Alignment.center,
      child: ListView(
        padding: EdgeInsets.all(30),
        shrinkWrap: true,
        children: [
          TextField (
            controller: phoneSController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
              border: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelStyle: TextStyle(
                  fontFamily: 'Beheshti',
                  fontWeight: FontWeight.normal,
                  fontSize: 20,
                  color: Colors.black
              ),
              labelText: 'شماره تماس',
            ),
          ),
          PasswordField(
            controller: passwordSController,
            inputDecoration: PasswordDecoration(
                inputStyle: TextStyle(
                    fontFamily: 'Beheshti',
                    fontWeight: FontWeight.normal,
                    fontSize: 17,
                    color: Colors.black
                ),
                hintStyle: TextStyle(
                    fontFamily: 'Beheshti',
                    fontWeight: FontWeight.normal,
                    fontSize: 20,
                    color: Colors.black
                ),
                errorStyle: TextStyle(
                    fontFamily: 'Beheshti',
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: Colors.redAccent
                )
            ),
            hintText: 'رمز عبور',
            passwordConstraint: r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$",
            border: PasswordBorder(
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blue.shade100,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blue.shade100,
                ),
              ),
              focusedErrorBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            errorMessage:
            'رمز عبور قابل قبول نیست',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: tryToLogin ? true : false,
      body: Stack(
        children: [
          SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Image.asset('assets/Beheshti.png', width: 150.0),
                ),
          )),
          tryToLogin ? _loginFields() : _signUpFields(),
          tryToLogin ? _loginButtons() : _signUpButtons()
        ],
      ),
    );
  }

}