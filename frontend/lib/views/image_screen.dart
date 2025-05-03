import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/clothing_service.dart';
import '../models/clothing_item.dart';
import '../widgets/clothing_item_card.dart';

class ImageScreen extends StatefulWidget {
  final ImageSource? source;
  final File? sharedImage;

  const ImageScreen({
    super.key,
    this.source,
    this.sharedImage,
  }) : assert(source != null || sharedImage != null);

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  File? _image;
  List<ClothingItem> _results = [];
  bool _isLoading = false;
  final _clothingService = ClothingService();
  final String backendUrl = 'http://10.0.2.2:8000';
  @override
  void initState() {
    super.initState();
    if (widget.sharedImage != null) {
      _processImage(widget.sharedImage!);
    } else {
      _pickAndUploadImage();
    }
  }

  Future<void> _processImage(File imageFile) async {
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
  }

  Future<void> _pickAndUploadImage() async {
    final picked = await ImagePicker().pickImage(source: widget.source!);
    if (picked != null) {
      final imageFile = File(picked.path);
      await _processImage(imageFile);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Results")),
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
