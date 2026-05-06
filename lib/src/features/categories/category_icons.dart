import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';

IconData iconForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return FlutterRemix.restaurant_2_line;
    case 'transport':
      return FlutterRemix.car_line;
    case 'shopping':
      return FlutterRemix.shopping_bag_3_line;
    case 'bills':
      return FlutterRemix.bill_line;
    case 'health':
      return FlutterRemix.medicine_bottle_line;
    case 'salary':
      return FlutterRemix.money_dollar_circle_line;
    default:
      return FlutterRemix.price_tag_3_line;
  }
}
