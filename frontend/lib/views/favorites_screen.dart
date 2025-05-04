import 'package:flutter/material.dart';
import '../base_scaffold.dart';
import '../models/clothing_item.dart';
import '../services/clothing_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

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
      print('Backend response: ${response.body}');  
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
        throw Exception('Error loading favorites: ${response.body}');
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
        SnackBar(content: Text("Error opening the link: $e")),
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
          const SnackBar(content: Text("Removed from favorites")),
        );
        setState(() {
          _favorites.remove(item);
        });
      } else {
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error removing: ${response.body}")),
        );
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error removing from favorites: $e")),
      );
    }
  }

  Widget _buildCard(ClothingItem item) {
    final bool hasDiscount = item.price.original != null &&
        item.price.original! > item.price.current;

    final double? discountPercentage = hasDiscount
        ? 100 * (item.price.original! - item.price.current) / item.price.original!
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),  
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.black, 
                        strokeWidth: 6,
                      ),
                    );
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
                      backgroundColor: Colors.black, 
                    ).copyWith(
                      side: MaterialStateProperty.all(BorderSide(color: Colors.black)), 
                    ),
                    child: Text(
                      "Buy",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white, 
                      ),
                    ),
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
                      side: BorderSide(color: Colors.black), 
                    ),
                    child: Text(
                      "Remove from Favorites",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black, 
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Favorites',
      username: widget.username,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.black, 
                strokeWidth: 6,
              ),
            )
          : _favorites.isEmpty
              ? const Center(child: Text("You have no favorite items yet."))
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
