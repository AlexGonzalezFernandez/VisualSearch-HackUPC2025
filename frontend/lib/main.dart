import 'package:flutter/material.dart';
import 'views/home_screen.dart';
import 'services/shared_media_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clothing Scanner',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const SharedMediaRoot(),
    );
  }
}

class SharedMediaRoot extends StatefulWidget {
  const SharedMediaRoot({super.key});

  @override
  State<SharedMediaRoot> createState() => _SharedMediaRootState();
}

class _SharedMediaRootState extends State<SharedMediaRoot> {
  late SharedMediaHandler _mediaHandler;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mediaHandler = SharedMediaHandler(context);
      _mediaHandler.handleInitialShare();
      _mediaHandler.listenToShares();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
