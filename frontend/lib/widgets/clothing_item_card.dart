import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/clothing_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/clothing_service.dart';
import 'package:google_fonts/google_fonts.dart';

class ClothingItemCard extends StatelessWidget {
  final ClothingItem item;

  const ClothingItemCard({super.key, required this.item});

  Future<void> _launchURL(BuildContext context) async {
    try {
      await launch(item.link);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error opening the link: $e")),
      );
    }
  }

  Future<void> _addToFavorites(BuildContext context) async {
    final url = Uri.parse('${ClothingService.baseUrl}/new-favorite/');

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
              'original': item.price.original,
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Added to favorites")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding to favorites: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Rounded corners
      ),
      elevation: 4, // Soft shadow to highlight the card
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
              style: GoogleFonts.montserrat( // Modern font
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
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
                      backgroundColor: Colors.black, // Dark background
                      foregroundColor: Colors.white, // White text
                    ),
                    child: Text(
                      "Buy Now",
                      style: GoogleFonts.montserrat( // Modern and elegant font
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _addToFavorites(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.black), // Black border
                    ),
                    child: Text(
                      "Add to Favorites",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat( // Modern font for the text
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black, // Black text
                      ),
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
