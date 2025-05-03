import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/clothing_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/clothing_service.dart';

class ClothingItemCard extends StatelessWidget {
  final ClothingItem item;

  const ClothingItemCard({super.key, required this.item});

  Future<void> _launchURL(BuildContext context) async {
    try {
      await launch(item.link);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al abrir el enlace: $e")),
      );
    }
  }

    Future<void> _addToFavorites(BuildContext context) async {
      final url = Uri.parse('${ClothingService.baseUrl}/new-favorite/'); // Replace with your FastAPI URL

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': item.name,
            'link': item.link,
            'image_url': item.imageUrl,
          }),
        );

        print(url);
        print(response);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Añadido a favoritos")),
          );
        } else {
          print(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error del servidor: ${response.body}")),
          );
        }
      } catch (e) {
        print(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al añadir a favoritos: $e")),
        );
      }
    }

  @override
  Widget build(BuildContext context) {
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
                aspectRatio: 1, // or try 4 / 3 for slightly taller images
                child: Image.network(
                  item.imageUrl,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                ),
              ),
            ),
            // Add a small vertical padding
            const SizedBox(height: 12),
            Text(
              item.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            if (item.price.original != null)
              Row(
                children: [
                  Text(
                    item.price.originalFormatted!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item.price.currentFormatted,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (item.price.discountPercentage != null)
                    Text(
                      '-${item.price.discountPercentage!.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                ],
              )
            else
              Text(
                '${item.price.currentFormatted}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _launchURL(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Comprar",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _addToFavorites(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Añadir a favoritos",
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
}
