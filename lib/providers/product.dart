import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toogleFavoriteStatus() async {
    final _oldStatus = isFavorite;
    isFavorite = !isFavorite;
    final url =
        'https://flutter-testing-course.firebaseio.com/products/$id.json';
    try {
      final _response = await http.patch(
        url,
        body: json.encode({
          'isFavorite': isFavorite,
        }),
      );
      notifyListeners();
      if (_response.statusCode >= 400) {
        isFavorite = _oldStatus;
        notifyListeners();
      }
    } catch (error) {
      isFavorite = _oldStatus;
      notifyListeners();
    }
  }
}
