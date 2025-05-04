import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Importa Google Fonts
import 'views/favorites_screen.dart';
import 'views/home_screen.dart';
import 'views/login_screen.dart';

class BaseScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final String username;

  const BaseScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.username,
  });

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(username: username),
      ),
    );
  }

  void _navigateToFavorites(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavoritesScreen(username: username),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Fondo oscuro para la barra de app
        title: Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Blanco para el texto
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Hacer las tres rayas blancas
      ),
      drawer: Drawer(
        child: Container(
          width: 200, // Ancho reducido para el Drawer
          color: Colors.grey[850], // Fondo oscuro para el Drawer
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.black, // Fondo oscuro para el encabezado
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hello, $username',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey, // Cambiado a gris
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.white),
                title: Text(
                  'Home',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                  ),
                ),
                onTap: () => _navigateToHome(context),
              ),
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.white),
                title: Text(
                  'Favourites',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                  ),
                ),
                onTap: () => _navigateToFavorites(context),
              ),
            ],
          ),
        ),
      ),
      body: Center( // Centrado del contenido en el cuerpo
        child: SingleChildScrollView( // 🛡 Evita overflow en pantallas pequeñas
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centrado vertical
            crossAxisAlignment: CrossAxisAlignment.center, // Centrado horizontal
            children: [
              body, // Coloca aquí el contenido del cuerpo
            ],
          ),
        ),
      ),
    );
  }
}
