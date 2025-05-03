import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clothing Scanner',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  void _navigateWithSource(BuildContext context, ImageSource source) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageScreen(source: source),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clothing Scanner')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
              onPressed: () => _navigateWithSource(context, ImageSource.camera),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Choose from Gallery'),
              onPressed: () => _navigateWithSource(context, ImageSource.gallery),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageScreen extends StatefulWidget {
  final ImageSource source;

  const ImageScreen({super.key, required this.source});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  File? _image;
  String _result = "";
  final String backendUrl = 'https://4e55-147-83-201-99.ngrok-free.app';

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
        _result = "Uploading...";
      });
      await _uploadImage(imageFile);
    } else {
      Navigator.pop(context); // Go back if no image selected
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      var uri = Uri.parse('$backendUrl/upload/');
      var request = http.MultipartRequest('POST', uri);

      final extension = imageFile.path.split('.').last.toLowerCase();
      final mediaType = extension == 'png' ? 'png' : 'jpeg';

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType('image', mediaType),
      ));

      var response = await request.send();
      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        setState(() {
          _result = respStr;
        });
      } else {
        setState(() {
          _result = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Upload failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Result")),
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
            Text(
              'Result:',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _result.isNotEmpty ? _result : 'No result yet.',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
