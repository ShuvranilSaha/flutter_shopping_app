import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFoucsNode = FocusNode();
  final _desciptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();

  var _editedProducts = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );
  var _isInit = true;

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateUrlImage);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProducts = Provider.of<ProductsProvider>(context, listen: false)
            .findById(productId);
        _initValues = {
          'title': _editedProducts.title,
          'description': _editedProducts.description,
          'price': _editedProducts.price.toString(),
          // 'imageUrl': _editedProducts.imageUrl
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProducts.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _updateUrlImage() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProducts.id != null) {
      Provider.of<ProductsProvider>(context, listen: false)
          .updateProducts(_editedProducts.id, _editedProducts);
      setState(() {
        _isLoading = false;
      });
    } else {
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProducts(_editedProducts);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text('Something went wrong.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(() {
      _updateUrlImage();
    });
    _priceFoucsNode.dispose();
    _desciptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('edit product'),
        actions: [
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                _saveForm();
              })
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(backgroundColor: Colors.black))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _initValues['title'],
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFoucsNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _editedProducts = Product(
                              id: _editedProducts.id,
                              isFavorite: _editedProducts.isFavorite,
                              title: newValue,
                              description: _editedProducts.description,
                              price: _editedProducts.price,
                              imageUrl: _editedProducts.imageUrl);
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['price'],
                        decoration: InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFoucsNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_desciptionFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please Enter your price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter your correct price';
                          }

                          if (double.parse(value) <= 0) {
                            return 'Price cannot be 0';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _editedProducts = Product(
                              id: _editedProducts.id,
                              isFavorite: _editedProducts.isFavorite,
                              title: _editedProducts.title,
                              description: _editedProducts.description,
                              price: double.parse(newValue),
                              imageUrl: _editedProducts.imageUrl);
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['description'],
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        focusNode: _desciptionFocusNode,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please Enter description';
                          }
                          if (value.length < 10) {
                            return 'Please enter more to describe';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _editedProducts = Product(
                              id: _editedProducts.id,
                              isFavorite: _editedProducts.isFavorite,
                              title: _editedProducts.title,
                              description: newValue,
                              price: _editedProducts.price,
                              imageUrl: _editedProducts.imageUrl);
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? Text('Enter a url!')
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Image Url'),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                controller: _imageUrlController,
                                focusNode: _imageUrlFocusNode,
                                onFieldSubmitted: (_) {
                                  _saveForm();
                                },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter an image URL.';
                                  }
                                  if (!value.startsWith('http') &&
                                      !value.startsWith('https')) {
                                    return 'Please enter a valid URL.';
                                  }
                                  if (!value.endsWith('.png') &&
                                      !value.endsWith('.jpg') &&
                                      !value.endsWith('.jpeg')) {
                                    return 'Please enter a valid image URL.';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  _editedProducts = Product(
                                      id: _editedProducts.id,
                                      isFavorite: _editedProducts.isFavorite,
                                      title: _editedProducts.title,
                                      description: _editedProducts.description,
                                      price: _editedProducts.price,
                                      imageUrl: newValue);
                                }),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        child: RaisedButton(
                          onPressed: () {
                            _saveForm();
                          },
                          padding: EdgeInsets.all(8),
                          color: Colors.white,
                          child: Text(
                            'Save Product',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                      )
                    ],
                  )),
            ),
    );
  }
}
