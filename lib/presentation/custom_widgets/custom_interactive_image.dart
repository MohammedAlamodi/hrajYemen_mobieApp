import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomInteractiveViewer extends StatelessWidget {
  final String? networkImage;
  final Uint8List? binaryImage;
  final File? fileImage;

  const CustomInteractiveViewer(
      {super.key, this.networkImage, this.binaryImage, this.fileImage});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: InteractiveViewer(
              constrained: true,
              maxScale: 4,
              minScale: 0.5,
              child: (binaryImage == null)
                  ? Image.file(fileImage!)
                  : Image.memory(binaryImage!),
            ),
          ),
        );
      },
      child: (binaryImage == null)
          ? Image.file(fileImage!)
          : Image.memory(binaryImage!),
    );
  }
}
