import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double ammount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.ammount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(
      List<CartItem> cartProducts, double totalAmmount) async {
    const url = 'https://flutter-testing-course.firebaseio.com/orders.json';
    final _timeStamp = DateTime.now();
    final _response = await http.post(
      url,
      body: json.encode({
        'amount': totalAmmount,
        'dateTime': _timeStamp.toIso8601String(),
        'products': cartProducts
            .map((e) => {
                  'id': e.id,
                  'title': e.title,
                  'quantity': e.quantity,
                  'price': e.price
                })
            .toList(),
      }),
    );
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(_response.body)['name'],
        ammount: totalAmmount,
        products: cartProducts,
        dateTime: _timeStamp,
      ),
    );
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    const url = 'https://flutter-testing-course.firebaseio.com/orders.json';
    final _response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(_response.body) as Map<String, dynamic>;

    if (extractedData == null) {
      return;
    }

    extractedData.forEach((key, value) {
      loadedOrders.add(
        OrderItem(
          id: key,
          ammount: value['amount'],
          products: (value['products'] as List<dynamic>)
              .map(
                (e) => CartItem(
                  id: e['id'],
                  title: e['title'],
                  quantity: e['quantity'],
                  price: e['price'],
                ),
              )
              .toList(),
          dateTime: DateTime.parse(
            value['dateTime'],
          ),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }
}
