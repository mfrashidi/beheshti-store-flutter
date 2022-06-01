import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CartScreen extends StatelessWidget {
  const CartScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "سبد خرید",
            style: TextStyle(
                fontFamily: 'Beheshti',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black
            )
        ),
        toolbarHeight: 100,
        centerTitle: true,
        leadingWidth: 10,
        backgroundColor: Colors.white.withOpacity(0.3),
        elevation: 0,
      ),
      body: Body(),
    );
  }
}

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isCartEmpty = true;
    List<Map<String, dynamic>> products = [
      {"logo": "assets/screens/profile/item.png",
        "text": "کالاهای من",
        "number": "۶"
      },
      {"logo": "assets/screens/profile/basket.png",
        "text": "سفارش ها",
        "number": "۱۴"
      },
    ];
    Stack emptyCart = Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              Image.asset(
                "assets/screens/cart/empty_cart.png",
                scale: 1.7,
              ),
              Text(
                "سبد خریدتان خالی می‌باشد   :(",
                style: TextStyle(fontFamily: 'Beheshti', fontWeight: FontWeight.bold, fontSize: 17),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
        // Align(
        //   alignment: Alignment.bottomCenter,
        //   child: Padding(
        //     padding: EdgeInsets.only(bottom: 35),
        //     child: ElevatedButton(
        //       onPressed: () {
        //         isCartEmpty = false;
        //       },
        //       style: ElevatedButton.styleFrom(
        //           primary: Color(0xFF4431B6),
        //           shadowColor: Colors.black.withOpacity(0.5),
        //           fixedSize: Size(200, 50),
        //           shape: new RoundedRectangleBorder(
        //             borderRadius: new BorderRadius.circular(10),
        //           )
        //       ),
        //       child: Text(
        //         "همین حالا خرید کنید",
        //         style: TextStyle(fontFamily: 'Beheshti', fontWeight: FontWeight.bold, fontSize: 17),
        //         textAlign: TextAlign.center,
        //       ),
        //     ),
        //   ),
        // )
      ]
    );

    GridView filledCart = GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2,
          crossAxisSpacing: 30,
          mainAxisSpacing: 30,
        ),
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Container(
                    child: Text("dara"),
                ),
              ),
            ),
          );
        }
    );
    return isCartEmpty ? emptyCart : filledCart;
  }
}