import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/clothing_service.dart';
import '../models/clothing_item.dart';
import '../widgets/clothing_item_card.dart';
import '../base_scaffold.dart';
import 'favorites_screen.dart';

class ImageScreen extends StatefulWidget {
  final ImageSource source;
  final String username;

  const ImageScreen({
    super.key,
    required this.source,
    required this.username,
  });

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  File? _image;
  List<ClothingItem> _results = [];
  bool _isLoading = false;
  final _clothingService = ClothingService();

  @override
  void initState() {
    super.initState();
    _pickAndUploadImage();
  }

  Future<void> _pickAndUploadImage() async {
    final picked = await ImagePicker().pickImage(source: widget.source);
    if (picked != null) {
      final imageFile = File(picked.path);
      setState(() {
        _image = imageFile;
        _results = [];
        _isLoading = true;
      });
      try {
        final results = await _clothingService.uploadImage(imageFile);
        setState(() {
          _results = results;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "Results",
      username: widget.username, // <-- aquí
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_image!, height: 250, fit: BoxFit.cover),
              ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_results.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _results.length,
                itemBuilder: (context, index) => ClothingItemCard(
                  item: _results[index],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
