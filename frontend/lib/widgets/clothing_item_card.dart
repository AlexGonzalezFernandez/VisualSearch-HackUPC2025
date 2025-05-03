import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/clothing_item.dart';

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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      fontSize: 20,
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
                'Price: ${item.price.currentFormatted}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _launchURL(context),
              child: const Text("Comprar"),
            ),
          ],
        ),
      ),
    );
  }
}
