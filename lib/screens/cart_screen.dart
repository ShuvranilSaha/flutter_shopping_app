import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/Orders.dart';
import 'package:shop_app/providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart-screen';

  @override
  Widget build(BuildContext context) {
    final _currentUserCart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Chip(
                    label: Text(
                      'Rs. ${_currentUserCart.totalAmmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.headline6.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(currentUserCart: _currentUserCart),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, i) => CartItem(
                id: _currentUserCart.items.values.toList()[i].id,
                productId: _currentUserCart.items.keys.toList()[i],
                title: _currentUserCart.items.values.toList()[i].title,
                quantity: _currentUserCart.items.values.toList()[i].quantity,
                price: _currentUserCart.items.values.toList()[i].price,
              ),
              itemCount: _currentUserCart.items.length,
            ),
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required Cart currentUserCart,
  })  : _currentUserCart = currentUserCart,
        super(key: key);

  final Cart _currentUserCart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading
          ? CircularProgressIndicator(
              backgroundColor: Theme.of(context).primaryColor,
            )
          : Text('Order Now'),
      onPressed: (widget._currentUserCart.totalAmmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false).addOrder(
                widget._currentUserCart.items.values.toList(),
                widget._currentUserCart.totalAmmount,
              );
              setState(() {
                _isLoading = false;
              });
              widget._currentUserCart.clear();
            },
      textColor: Theme.of(context).primaryColor,
    );
  }
}
