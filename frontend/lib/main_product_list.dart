import 'package:flutter/material.dart';
    import 'views/products_list_view.dart'; // Import the ProductListView

    void main() {
      runApp(const MyApp());
    }

    class MyApp extends StatelessWidget {
      const MyApp({Key? key}) : super(key: key);

      @override
      Widget build(BuildContext context) {
        return MaterialApp(
          home: ProductListView(), // Display the ProductListView here
        );
      }
    }
