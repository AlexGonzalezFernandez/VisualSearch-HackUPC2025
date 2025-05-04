import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Importa Google Fonts
import 'package:animated_text_kit/animated_text_kit.dart'; // Importa la librería correcta para animaciones
import 'home_screen.dart'; // Importa la HomeScreen correcta desde tu archivo.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _submit() {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(username: username)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingrese ambos campos.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // 🛡 Evita overflow en pantallas pequeñas
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // 🧱 Botón ocupa todo el ancho
          children: [
            const SizedBox(height: 40),
            // Logo de Inditex con algo de espacio arriba
            Image.asset('assets/images/inditex_logo.png', height: 200),
            const SizedBox(height: 20),
            // Título con fuente fancy y animación
            Center(
              child: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Welcome', // El texto que va a ser animado
                    textStyle: GoogleFonts.playfairDisplay( // Fuente más fancy y elegante
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    speed: const Duration(milliseconds: 300), // Velocidad más lenta
                  ),
                ],
                totalRepeatCount: 1, // Se repite solo una vez
                pause: const Duration(seconds: 1), // Pausa después de la animación
              ),
            ),
            const SizedBox(height: 30),
            // Campo de usuario
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: GoogleFonts.montserrat( // Fuente más moderna para el label
                  fontSize: 16,
                  color: Colors.black54,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Campo de contraseña
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: GoogleFonts.montserrat( // Fuente más moderna para el label
                  fontSize: 16,
                  color: Colors.black54,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Botón de "Sign In" con estilo Inditex
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.black, // Fondo negro al estilo Inditex
                foregroundColor: Colors.white, // Texto blanco
              ),
              child: Text(
                'Sign In',
                style: GoogleFonts.playfairDisplay( // Fuente fancy para el botón
                  fontSize: 16,
                  fontWeight: FontWeight.bold, // Más énfasis en el texto
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
