import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:url_launcher/url_launcher.dart'; // Importamos url_launcher

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
  List<dynamic> _results = [];
  bool _isLoading = false;
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
        _results = [];
        _isLoading = true;
      });
      await _uploadImage(imageFile);
    } else {
      Navigator.pop(context);
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
          _results = json.decode(respStr);
          _isLoading = false;
        });
      } else {
        setState(() {
          _results = [
            {"name": "Error", "value": "Status ${response.statusCode}"}
          ];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _results = [
          {"name": "Error", "value": "Upload failed: $e"}
        ];
        _isLoading = false;
      });
    }
  }

  // Función para lanzar la URL
  Future<void> _launchURL(String url) async {
    try {
      // Usamos launch para intentar abrir la URL
      await launch(url);
    } catch (e) {
      // En caso de que haya un error al abrir el URL, mostramos un mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al abrir el enlace: $e")),
      );
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
            if (_isLoading) // Muestra la pantalla de carga
              Center(
                child: CircularProgressIndicator(),
              )
            else if (_results.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final item = _results[index];

                  // Obtiene el precio actual
                  var price = item['price']['value']['current'] ?? 0.0;
                  var currency = item['price']['currency'] ?? 'USD';
                  var originalPrice = item['price']['value']['original'];

                  // Si la moneda es EUR, muestra el símbolo €
                  String formatPrice(double price) {
                    return currency == 'EUR' ? '$price€' : '$price $currency';
                  }

                  String priceText = formatPrice(price);
                  String originalPriceText = originalPrice != null ? formatPrice(originalPrice) : '';

                  // Calcular porcentaje de descuento
                  double discountPercentage = 0.0;
                  if (originalPrice != null && originalPrice > 0) {
                    discountPercentage = ((originalPrice - price) / originalPrice) * 100;
                  }

                  // URL de ejemplo para el botón "Comprar"
                  String buyLink = item['link']; 

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? 'No name',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          if (originalPrice != null) // Si hay precio original, mostrarlo tachado
                            Row(
                              children: [
                                Text(
                                originalPriceText,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.red, // Color del texto (precio original)
                                  decoration: TextDecoration.lineThrough, // Tachado
                                  decorationColor: Colors.red, // Color del tachado
                                ),
                              ),

                                const SizedBox(width: 10),
                                Text(
                                  priceText, // Precio actual en negrita
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '-${discountPercentage.toStringAsFixed(0)}%', // Descuento a la derecha
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green, // Color de descuento
                                  ),
                                ),
                              ],
                            )
                          else // Si no hay precio original, solo mostrar el precio actual
                            Text(
                              'Price: $priceText',
                              style: const TextStyle(fontSize: 16),
                            ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              _launchURL(buyLink); // Llama a la función para abrir la URL
                            },
                            child: const Text("Comprar"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
          ],
        ),
      ),
    );
  }


}
