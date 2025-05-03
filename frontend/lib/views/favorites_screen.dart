import 'package:flutter/material.dart';
import '../base_scaffold.dart';

class FavoritesScreen extends StatelessWidget {
  final String username;

  const FavoritesScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Favoritos',
      username: username, // <-- Esto es lo que faltaba
      body: const Center(child: Text('Aquí van tus favoritos')),
    );
  }
}

