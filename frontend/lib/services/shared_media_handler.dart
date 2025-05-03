import 'dart:io';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../views/image_screen.dart';

class SharedMediaHandler {
  final BuildContext context;

  SharedMediaHandler(this.context);

  void handleSharedFile(File file) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ImageScreen(sharedImage: file)),
    );
  }

  Future<void> handleInitialShare() async {
    if (!Platform.isAndroid && !Platform.isIOS)
      return; // Skip unsupported platforms.
    try {
      final List<SharedMediaFile> files =
          await ReceiveSharingIntent.instance.getInitialMedia();
      if (files.isNotEmpty && files.first.path.isNotEmpty) {
        handleSharedFile(File(files.first.path));
      }
    } catch (e) {
      debugPrint('Error handling initial share: $e');
    }
  }

  void listenToShares() {
    if (!Platform.isAndroid && !Platform.isIOS)
      return; // Skip unsupported platforms.
    ReceiveSharingIntent.instance.getMediaStream().listen((
      List<SharedMediaFile> files,
    ) {
      if (files.isNotEmpty && files.first.path.isNotEmpty) {
        handleSharedFile(File(files.first.path));
      }
    });
  }
}
