import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductWidget extends StatelessWidget {
  final Product product;

  const ProductWidget({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                print('Added ${product.name} to cart');
              },
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}