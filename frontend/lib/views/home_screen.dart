import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Importa Google Fonts
import 'package:image_picker/image_picker.dart';
import '../base_scaffold.dart';
import 'image_screen.dart';

class HomeScreen extends StatelessWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  void _navigateWithSource(BuildContext context, ImageSource source) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageScreen(source: source, username: username),
      ),
    );
  }

  ButtonStyle _inditexButtonStyle(Color backgroundColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ).copyWith(
      overlayColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.hovered)) {
            return Colors.grey[800]; // Hover gris oscuro
          }
          return null; // Por defecto usa el color base
        },
      ),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Texto siempre blanco
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: '',
      username: username,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Título con fuente fancy
            Text(
              'Escanea tu ropa',
              style: GoogleFonts.playfairDisplay( // Aplica la fuente fancy aquí
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Botón para tomar una foto
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text('Tomar foto'),
                onPressed: () => _navigateWithSource(context, ImageSource.camera),
                style: _inditexButtonStyle(Colors.black),
              ),
            ),
            const SizedBox(height: 16),
            // Botón para elegir de la galería
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.image, color: Colors.white),
                label: const Text('Elegir de galería'),
                onPressed: () => _navigateWithSource(context, ImageSource.gallery),
                style: _inditexButtonStyle(Colors.grey[900]!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
