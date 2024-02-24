import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package
import 'package:eldergit/ShoppingCart/Shop.dart';
import 'package:eldergit/ShoppingCart/ProductList.dart';

class ShopPage extends StatelessWidget {
  final Shop shop;

  const ShopPage({Key? key, required this.shop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: shop.shop.length,
        padding: const EdgeInsets.all(15),
        itemBuilder: (context, index) {
          final product = shop.shop[index];
          return GestureDetector(
            onTap: () {
              openBrowserURL(url: "https://www.lazada.com.my/", inApp: true);
            },
            child: ProductList(product: product),
          );
        },
      ),
    );
  }

  Future<void> openBrowserURL({
    required String url,
    bool inApp = false,
  }) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: inApp,
        forceWebView: inApp,
        enableJavaScript: true,
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}
