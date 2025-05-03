import 'package:flutter/material.dart';
import '../base_scaffold.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Favoritos',
      body: const Center(
        child: Text('Aquí se mostrarán tus favoritos.'),
      ),    
    );
  }
}
