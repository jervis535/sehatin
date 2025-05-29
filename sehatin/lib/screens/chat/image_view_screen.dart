import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageViewScreen extends StatelessWidget {
  final Uint8List imageBytes;

  const ImageViewScreen({Key? key, required this.imageBytes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          scaleEnabled: true,
          child: Image.memory(imageBytes),
        ),
      ),
    );
  }
}
