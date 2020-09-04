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

  Future<void> toogleFavoriteStatus(String token, String userId) async {
    final _oldStatus = isFavorite;
    isFavorite = !isFavorite;
    final url =
        'https://flutter-testing-course.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    try {
      final _response = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
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
