import 'package:flutter/material.dart';
import '../widgets/product_widget.dart';
import '../models/product.dart';

class ProductListView extends StatefulWidget {
  const ProductListView({Key? key}) : super(key: key);

  @override
  _ProductListViewState createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final List<Product> _mock_products = [
    Product(name: 'T-Shirt', price: 29.99),
    Product(name: 'Jeans', price: 49.99),
    Product(name: 'Jacket', price: 79.99),
    Product(name: 'Shoes', price: 59.99),
    Product(name: 'Hat', price: 19.99),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
      ),
      body: ListView.builder(
        itemCount: _mock_products.length,
        itemBuilder: (context, index) {
          return ProductWidget(product: _mock_products[index]);
        },
      ),
    );
  }
}