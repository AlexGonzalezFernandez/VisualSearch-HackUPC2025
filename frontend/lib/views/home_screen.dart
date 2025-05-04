import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
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
            return Colors.grey[800]; // Hover effect for dark grey
          }
          return null; // Default color remains unchanged
        },
      ),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Always white text
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
            // Stylish title with a fancy font
            Text(
              'Scan your outfit',
              style: GoogleFonts.playfairDisplay( // Applying fancy font here
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Button to take a photo
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: Text(
                  'Take a photo',
                  style: GoogleFonts.poppins( // Stylish font for the button
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2, // Adds a little extra style
                  ),
                ),
                onPressed: () => _navigateWithSource(context, ImageSource.camera),
                style: _inditexButtonStyle(Colors.black),
              ),
            ),
            const SizedBox(height: 16),
            // Button to choose from gallery
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.image, color: Colors.white),
                label: Text(
                  'Choose from gallery',
                  style: GoogleFonts.poppins( // Stylish font for the button
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2, // Adds a little extra style
                  ),
                ),
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
