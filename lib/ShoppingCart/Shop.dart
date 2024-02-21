import 'package:eldergit/ShoppingCart/product.dart';
import 'package:flutter/cupertino.dart';

class Shop extends ChangeNotifier{
  final List<Product> _shop = [
    Product(
        name: "10pcs/Bag Adult Diaper Pull-ups Pants Disposable Diapers Care Adult Diapers for Senior Women Elderly Men Pregnant Women",
        price: 10.99,
        description:
        "https://www.lazada.com.my/products/10pcsbag-adult-diaper-pull-ups-pants-disposable-diapers-care-adult-diapers-for-senior-women-elderly-men-pregnant-women-i3864031190-s22320413677.html?c=&channelLpJumpArgs=&clickTrackInfo=query%253Aelderly%252Bcare%252Bproducts%253Bnid%253A3864031190%253Bsrc%253ALazadaMainSrp%253Brn%253Afb2c5d893c52c60b3888a1e12fbfaac8%253Bregion%253Amy%253Bsku%253A3864031190_MY%253Bprice%253A10.99%253Bclient%253Adesktop%253Bsupplier_id%253A300286032887%253Bbiz_source%253Ahttps%253A%252F%252Fwww.lazada.com.my%252F%253Bslot%253A4%253Butlog_bucket_id%253A470687%253Basc_category_id%253A10045%253Bitem_id%253A3864031190%253Bsku_id%253A22320413677%253Bshop_id%253A2737890&fastshipping=0&freeshipping=0&fs_ab=2&fuse_fs=&lang=en&location=Selangor&price=10.99&priceCompare=skuId%3A22320413677%3Bsource%3Alazada-search-voucher%3Bsn%3Afb2c5d893c52c60b3888a1e12fbfaac8%3BunionTrace%3A2102fcd717085348207101307e36e2%3BoriginPrice%3A1099%3BvoucherPrice%3A1099%3BdisplayPrice%3A1099%3BsinglePromotionId%3A-1%3BsingleToolCode%3AmockedSalePrice%3BvoucherPricePlugin%3A1%3BbuyerId%3A0%3Btimestamp%3A1708534821249&ratingscore=0&request_id=fb2c5d893c52c60b3888a1e12fbfaac8&review=&sale=0&search=1&source=search&spm=a2o4k.searchlist.list.4&stock=1"
    ),

    Product(
        name: "Elderly Turning Over Aid, Bed Support for Elderly, Care Products Elderly bed turn over",
        price: 44.00,
        description:
        "https://www.lazada.com.my/products/elderly-turning-over-aid-bed-support-for-elderly-care-products-elderly-bed-turn-over-i3029363721-s15515550947.html?c=&channelLpJumpArgs=&clickTrackInfo=query%253Aelderly%252Bcare%252Bproducts%253Bnid%253A3029363721%253Bsrc%253ALazadaMainSrp%253Brn%253Afb2c5d893c52c60b3888a1e12fbfaac8%253Bregion%253Amy%253Bsku%253A3029363721_MY%253Bprice%253A44%253Bclient%253Adesktop%253Bsupplier_id%253A1000015532%253Bbiz_source%253Ahttps%253A%252F%252Fwww.lazada.com.my%252F%253Bslot%253A2%253Butlog_bucket_id%253A470687%253Basc_category_id%253A1692%253Bitem_id%253A3029363721%253Bsku_id%253A15515550947%253Bshop_id%253A218167&fastshipping=0&freeshipping=1&fs_ab=2&fuse_fs=&lang=en&location=Wp%20Kuala%20Lumpur&price=44&priceCompare=skuId%3A15515550947%3Bsource%3Alazada-search-voucher%3Bsn%3Afb2c5d893c52c60b3888a1e12fbfaac8%3BunionTrace%3A2102fcd717085348207101307e36e2%3BoriginPrice%3A4400%3BvoucherPrice%3A4400%3BdisplayPrice%3A4400%3BsinglePromotionId%3A-1%3BsingleToolCode%3AmockedSalePrice%3BvoucherPricePlugin%3A1%3BbuyerId%3A0%3Btimestamp%3A1708534821249&ratingscore=5.0&request_id=fb2c5d893c52c60b3888a1e12fbfaac8&review=1&sale=7&search=1&source=search&spm=a2o4k.searchlist.list.2&stock=1"
    ),

    Product(
        name: "GT MEDIT GERMANY Adjustable Height Medical Foldable Flexible Cane Walker Crutch Aid Mobility Stick / Tongkat",
        price: 10.65,
        description:
        "https://www.lazada.com.my/products/gt-medit-germany-adjustable-height-medical-foldable-flexible-cane-walker-crutch-aid-mobility-stick-tongkat-i1600294442-s5461552705.html?c=&channelLpJumpArgs=&clickTrackInfo=query%253Aelderly%252Bcare%252Bproducts%253Bnid%253A1600294442%253Bsrc%253ALazadaMainSrp%253Brn%253Afb2c5d893c52c60b3888a1e12fbfaac8%253Bregion%253Amy%253Bsku%253A1600294442_MY%253Bprice%253A10.65%253Bclient%253Adesktop%253Bsupplier_id%253A300146175023%253Bbiz_source%253Ahttps%253A%252F%252Fwww.lazada.com.my%252F%253Bslot%253A5%253Butlog_bucket_id%253A470687%253Basc_category_id%253A1692%253Bitem_id%253A1600294442%253Bsku_id%253A5461552705%253Bshop_id%253A1399221&fastshipping=0&freeshipping=0&fs_ab=2&fuse_fs=&lang=en&location=Selangor&price=10.65&priceCompare=skuId%3A5461552705%3Bsource%3Alazada-search-voucher%3Bsn%3Afb2c5d893c52c60b3888a1e12fbfaac8%3BunionTrace%3A2102fcd717085348207101307e36e2%3BoriginPrice%3A1065%3BvoucherPrice%3A1065%3BdisplayPrice%3A1065%3BsinglePromotionId%3A-1%3BsingleToolCode%3AmockedSalePrice%3BvoucherPricePlugin%3A1%3BbuyerId%3A0%3Btimestamp%3A1708534821249&ratingscore=4.866141732283465&request_id=fb2c5d893c52c60b3888a1e12fbfaac8&review=127&sale=443&search=1&source=search&spm=a2o4k.searchlist.list.5&stock=1"
    ),

    Product(
        name: "Elderly people's urinary incontinence underwear, adult urine leakage diaper pad, anti-leakage bedwetting artifact, toilet supplies, diaper pants",
        price: 10.99,
        description:
        "https://www.lazada.com.my/products/elderly-peoples-urinary-incontinence-underwear-adult-urine-leakage-diaper-pad-anti-leakage-bedwetting-artifact-toilet-supplies-diaper-pants-i3848856063-s22217255978.html?c=&channelLpJumpArgs=&clickTrackInfo=query%253Aelderly%252Bcare%252Bproducts%253Bnid%253A3848856063%253Bsrc%253ALazadaMainSrp%253Brn%253Afb2c5d893c52c60b3888a1e12fbfaac8%253Bregion%253Amy%253Bsku%253A3848856063_MY%253Bprice%253A29.9%253Bclient%253Adesktop%253Bsupplier_id%253A300168717459%253Bbiz_source%253Ahttps%253A%252F%252Fwww.lazada.com.my%252F%253Bslot%253A9%253Butlog_bucket_id%253A470687%253Basc_category_id%253A5278%253Bitem_id%253A3848856063%253Bsku_id%253A22217255978%253Bshop_id%253A2303726&fastshipping=0&freeshipping=1&fs_ab=2&fuse_fs=&lang=en&location=Overseas&price=29.9&priceCompare=skuId%3A22217255978%3Bsource%3Alazada-search-voucher%3Bsn%3Afb2c5d893c52c60b3888a1e12fbfaac8%3BunionTrace%3A2102fcd717085348207101307e36e2%3BoriginPrice%3A2990%3BvoucherPrice%3A2990%3BdisplayPrice%3A2990%3BsinglePromotionId%3A-1%3BsingleToolCode%3AmockedSalePrice%3BvoucherPricePlugin%3A1%3BbuyerId%3A0%3Btimestamp%3A1708534821249&ratingscore=5.0&request_id=fb2c5d893c52c60b3888a1e12fbfaac8&review=1&sale=20&search=1&source=search&spm=a2o4k.searchlist.list.9&stock=1"
    ),
  ];

  //user cart
  List<Product> _cart = [];

  //get product list
List<Product>get shop => _shop;

//get user cart
List<Product> get cart => _cart;
}