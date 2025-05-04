import 'package:flutter/material.dart';
import '../base_scaffold.dart';
import '../models/clothing_item.dart';
import '../services/clothing_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class FavoritesScreen extends StatefulWidget {
  final String username;
  const FavoritesScreen({super.key, required this.username});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<ClothingItem> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
      final url = Uri.parse('${ClothingService.baseUrl}/favorites/');
      try {
        final response = await http.get(url);
        print('Respuesta backend: ${response.body}');  // 👈 Añade esto
        if (response.statusCode == 200) {
          List<dynamic> data = jsonDecode(response.body);
          setState(() {
            _favorites = data
                .map((itemJson) => ClothingItem.fromJson(itemJson))
                .toList()
                .cast<ClothingItem>();
            _isLoading = false;
          });
        } else {
          throw Exception('Error al cargar favoritos: ${response.body}');
        }
      } catch (e) {
        print(e);
        setState(() => _isLoading = false);
      }
    }

  Future<void> _launchURL(String url) async {
    try {
      await launch(url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al abrir el enlace: $e")),
      );
    }
  }

  Future<void> _removeFromFavorites(BuildContext context, ClothingItem item) async {
      final url = Uri.parse('${ClothingService.baseUrl}/delete-favorite/');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': item.name,
            'link': item.link,
            'image_url': item.imageUrl,
            'price': {
              'currency': item.price.currency,
              'value': {
                'current': item.price.current,
                'original': item.price.original
              }
            }
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Eliminado de favoritos")),
          );
          setState(() {
            _favorites.remove(item);
          });
        } else {
          print(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error al eliminar: ${response.body}")),
          );
        }
      } catch (e) {
        print(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar de favoritos: $e")),
        );
      }
    }

  Widget _buildCard(ClothingItem item) {
      final bool hasDiscount = item.price.original != null &&
          item.price.original! > item.price.current;

      final double? discountPercentage = hasDiscount
          ? 100 *
              (item.price.original! - item.price.current) /
              item.price.original!
          : null;

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (hasDiscount)
                    Text(
                      '${item.price.originalFormatted}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Colors.red,
                      ),
                    ),
                  if (hasDiscount) const SizedBox(width: 10),
                  Text(
                    item.price.currentFormatted,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (discountPercentage != null)
                    Text(
                      '-${discountPercentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _launchURL(item.link),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Comprar", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _removeFromFavorites(context, item),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Eliminar de favoritos",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }


  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Favoritos',
      username: widget.username,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(child: Text("No tienes elementos favoritos aún."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    return _buildCard(_favorites[index]);
                  },
                ),
    );
  }
}
