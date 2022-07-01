import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/converter.dart';
import 'category_screen.dart';

Map<String, dynamic> product = {};

TextEditingController nameController = TextEditingController();
TextEditingController sellerNameController = TextEditingController();
TextEditingController priceController = TextEditingController();
TextEditingController stockController = TextEditingController();


class AddNewProductScreen extends StatefulWidget {
  AddNewProductScreen([Map<String, dynamic> p = const {}]) {
    product = p;
  }


  @override
  _AddNewProductScreenState createState() => _AddNewProductScreenState();
}

List<String> items = [];
List<String> itemIDs = [];
String? selectedValue;

Map<String, Color> colors = {};
Map<String, String> attributes = {};
List<double> sizes = [];

Color pickerColor = Color(0xff443a49);
Color currentColor = Color(0xff443a49);

TextEditingController colorNameController = TextEditingController();
TextEditingController sizeController = TextEditingController();

int categoryIndex = -1;

class _AddNewProductScreenState extends State<AddNewProductScreen> {

  File? _image;

  final _picker = ImagePicker();
  Future<void> _openImagePicker() async {
    final XFile? pickedImage =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  String persianize(String number) {
    List<String> persianNumbers = ["۰", "۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹" ];
    for (int i = 0; i < 10; i++) {
      number = number.replaceAll(i.toString(), persianNumbers[i]);
    }
    return number;
  }

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

  Future<String> _getImageBase64(String imageID) async {
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

  Future<void> _getCategories() async {
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      serverSocket.write("AUTH=" + token + ";GET_CATEGORIES\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        final data = await json.decode(utf8.decode(response));
        int i = 0;
        setState(() {
          Map<String, dynamic> categoriesMap = data;
          items = [];
          itemIDs = [];
          categoriesMap.forEach((key, value) {
            Map<String, dynamic> subCategories = value["sub_categories"];
            subCategories.forEach((k, v) {
              items.add(value["name"] + "، " + v["name"]);
              itemIDs.add(key + "_" + k);
              if (product["sub_category"] == key + "_" + k) {
                categoryIndex = i;
              }
              i++;
            });
          });
        });
      });
    });
  }

  Future<void> _save() async{
    await Socket.connect("192.168.1.7", 4536).then((serverSocket) async {
      String token = await getToken() ?? "nothing";
      List<int> imageBytes = _image?.readAsBytesSync() as List<int>;
      List<Map<String, String>> colorsMap = [];
      for (String name in colors.keys) {
        colorsMap.add({
          "name": unNormalize(name),
          "code": colors[name].toString().replaceAll("Color(", "").replaceAll(")", "")
        });
      }
      Map<String, String> attrs = {};
      for (String key in attributes.keys) {
        attrs[unNormalize(key)] = unNormalize(attributes[key]!);
      }
      Map<String, dynamic> pr = {
        "name": unNormalize(nameController.text),
        "stock": int.parse(stockController.text),
        "image": _image != null ? base64Encode(imageBytes) : product["image"],
        "images_count": 0,
        "category": items[categoryIndex],
        "sub_category": itemIDs[categoryIndex],
        "stars": product.isNotEmpty ? product["stars"] : 0,
        "has_color": colors.isNotEmpty,
        "colors": colorsMap,
        "has_size": sizes.isNotEmpty,
        "sizes": sizes,
        "description": attrs,
        "seller": product.isNotEmpty ? product["seller"] : "",
        "seller_name": unNormalize(sellerNameController.text),
        "product_id": product.isNotEmpty ? product["product_id"] : "",
        "price": int.parse(priceController.text)
      };
      serverSocket.write("AUTH=" + token + ";UPDATE_PRODUCT="+json.encode(pr)+"\n");
      serverSocket.flush();
      serverSocket.listen((response) async {
        setState(() {
          if (utf8.decode(response) == "DONE") {
            Fluttertoast.showToast(
              msg: "کالای شما با موفقیت ثبت شد",
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
    });
  }

  @override
  void initState() {
    super.initState();
    categoryIndex = -1;
    if (product.isEmpty) {
      colors = {};
      sizes = [];
      items = [];
      attributes = {};
    } else {
      WidgetsBinding.instance?.addPostFrameCallback((_) async {
        product["image"] = await _getImageBase64(product["image"]);
      });
      nameController.text = product["name"];
      sellerNameController.text = product["seller_name"];
      priceController.text = product["price"].toString();
      stockController.text = product["stock"].toString();
      colors = {};
      for (var i in product["colors"]) {
        colors[i["name"]] = Color(int.parse(i["code"]));
      }
      attributes = {};
      for (var i in product["description"].keys) {
        attributes[i] = product["description"][i];
      }
      sizes = [];
      for (var i in product["sizes"]) {
        sizes.add(i);
      }
    }
    _getCategories();
  }

  Widget _colorWidget(String name, Color? color) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                  name,
                  style: TextStyle(
                      fontFamily: 'Beheshti',
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                      color: color
                  )
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: CircleAvatar(
            radius: 12,
            backgroundColor: color!.withAlpha(150),
            child: CircleAvatar(radius: 7, backgroundColor: color),
          ),
        )
      ],
    );
  }

  Widget _sizeWidget(String size) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 1.5),
        ],
      ),
      child: Text(
          size,
          style: TextStyle(
              fontFamily: 'Beheshti',
              fontWeight: FontWeight.normal,
              fontSize: 12,
              color: Colors.black
          )
      ),
    );
  }

  Widget _attributeWidget(String k, String? v) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
              k,
              style: TextStyle(
                  fontFamily: 'Beheshti',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black
              )
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
              v!,
              style: TextStyle(
                  fontFamily: 'Beheshti',
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.5)
              )
          ),
        ),
        SizedBox(height: 30)
      ],
    );
  }

  void _showColorDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                "اضافه کردن رنگ جدید",
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
                      controller: colorNameController,
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
                        labelText: 'نام رنگ',
                      ),
                    ),
                    SizedBox(height: 20),
                    ColorPicker(
                      pickerColor: pickerColor,
                      onColorChanged: changeColor,
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
                      colors[colorNameController.text] = pickerColor;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
          );
        });
  }

  void _showSizeDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                "اضافه کردن سایز جدید",
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
                    controller: sizeController,
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
                      labelText: 'اندازه',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ),
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
                    sizes.add(double.parse(sizeController.text));
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _showAttributeDialog() {
    TextEditingController attController = new TextEditingController();
    TextEditingController desController = new TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                "اضافه کردن ویژگی جدید",
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
                      labelText: 'ویژگی',
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
                      labelText: 'توضیحات',
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
                    attributes[attController.text] = desController.text;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Widget _availableColors() {
    List<String> colorKeys = [];
    for (String k in colors.keys) {
      colorKeys.add(k);
    }
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        Stack(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                  "رنگ بندی",
                  style: TextStyle(
                      fontFamily: 'Beheshti',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black
                  )
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  _showColorDialog();
                },
                child: Text(
                    "اضافه کردن رنگ جدید",
                    style: TextStyle(
                        fontFamily: 'Beheshti',
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                        color: Colors.lightBlue
                    )
                ),
              ),
            )
          ],
        ),
        SizedBox(height: 10),
        ListView.separated(
            separatorBuilder: (context, index) => SizedBox(
              height: 10,
            ),
        shrinkWrap: true,
        itemCount: colors.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: _colorWidget(colorKeys[index], colors[colorKeys[index]]),
            onLongPress: (){
              setState(() {
                colors.remove(colorKeys[index]);
                colorKeys.removeAt(index);
              });
            },
          );
        }),
      ],
    );
  }

  Widget _availableSizes() {
    List<Widget> sizesWidgets = [];
    for (var size in sizes) {
      sizesWidgets.add(
        GestureDetector(
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
              child: _sizeWidget(persianize(size.toString()))
          ),
          onLongPress: () {
            setState(() {
              sizes.removeAt(sizes.indexOf(size));
            });
          },
        )
      );
    }
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        Stack(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                  "سایز",
                  style: TextStyle(
                      fontFamily: 'Beheshti',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black
                  )
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  _showSizeDialog();
                },
                child: Text(
                    "اضافه کردن سایز جدید",
                    style: TextStyle(
                        fontFamily: 'Beheshti',
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                        color: Colors.lightBlue
                    )
                ),
              ),
            )
          ],
        ),
        SizedBox(height: 10),
        Container(
          height: 30,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: sizesWidgets,
          ),
        ),
      ],
    );
  }

  Widget _attributes() {
    List<String> keys = [];
    for (var key in attributes.keys) {
      keys.add(key);
    }
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        Stack(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                  "ویژگی ها",
                  style: TextStyle(
                      fontFamily: 'Beheshti',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black
                  )
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  _showAttributeDialog();
                },
                child: Text(
                    "اضافه کردن ویژگی جدید",
                    style: TextStyle(
                        fontFamily: 'Beheshti',
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                        color: Colors.lightBlue
                    )
                ),
              ),
            )
          ],
        ),
        SizedBox(height: 10),
        ListView.builder(
          itemCount: attributes.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return GestureDetector(
              child: _attributeWidget(keys[index], attributes[keys[index]]),
              onLongPress: () {
                setState(() {
                  attributes.remove(keys[index]);
                  keys.remove(index);
                });
              },
            );
          }
          )
      ],
    );
  }

  Widget _getImage() {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        Stack(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                  "تصویر",
                  style: TextStyle(
                      fontFamily: 'Beheshti',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black
                  )
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  _openImagePicker();
                },
                child: Text(
                    "انتخاب عکس",
                    style: TextStyle(
                        fontFamily: 'Beheshti',
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                        color: Colors.lightBlue
                    )
                ),
              ),
            )
          ],
        ),
        SizedBox(height: 20),
        Container(
          child: _image != null
              ? Image.file(_image!, fit: BoxFit.cover)
              : product.isNotEmpty && (product["image"] as String).length > 1000 ? Image.memory(Uint8List.fromList(base64Decode(product["image"])), fit: BoxFit.cover) : Text('عکسی انتخاب نشده است',
              style: TextStyle(
                  fontFamily: 'Beheshti',
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                  color: Colors.black.withOpacity(0.5)
              )
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              "کالای جدید",
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
                    _save();
                  },
                  child: Text(
                      "ثبت",
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
          )
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              "میتوانید با نگه داشتن هرکدام از ویژگی ها، آن را حذف کنید",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Beheshti',
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                  color: Colors.black.withOpacity(0.5)
              ),
            ),
            SizedBox(height: 40),
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
                labelText: 'نام کالا',
            ),
          ),
            SizedBox(height: 30),
          DropdownButtonHideUnderline(
          child: DropdownButton2(
                  hint: Text(
            'دسته بندی',
            style: TextStyle(
                fontFamily: 'Beheshti',
                fontWeight: FontWeight.normal,
                fontSize: 17,
                color: Colors.black
            ),
            ),
            items: items
                .map((item) =>
            DropdownMenuItem<String>(
            value: item,
            child: Text(
            item,
            style: TextStyle(
                fontFamily: 'Beheshti',
                fontWeight: FontWeight.normal,
                fontSize: 17,
                color: Colors.black
            ),
            ),
            ))
                .toList(),
            value: categoryIndex != -1 ? items[categoryIndex] : selectedValue,
            onChanged: (value) {
            setState(() {
            selectedValue = value as String;
            categoryIndex = items.indexOf(value);
            });
            },
            buttonHeight: 60,
            buttonWidth: 140,
              buttonPadding: EdgeInsets.all(10),
            itemHeight: 50,
            buttonDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.black.withOpacity(0.5),
              ),
            )
            ),
          ),
            SizedBox(height: 30),
            TextFormField (
              controller: sellerNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
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
                labelText: 'نام فروشنده',
              ),
            ),
            SizedBox(height: 30),
            TextFormField (
              controller: priceController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
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
                labelText: 'قیمت',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
            SizedBox(height: 30),
            TextFormField (
              controller: stockController,
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
                labelText: 'موجودی کالا',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
            SizedBox(height: 30),
            _availableColors(),
            SizedBox(height: 30),
            _availableSizes(),
            SizedBox(height: 30),
            _attributes(),
            SizedBox(height: 30),
            _getImage()
        ],
        ),
      ),
    );
  }
}