import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ye_hraj/configurations/data/end_points_manager.dart';

class CustomProductImageAvatar extends StatelessWidget {
  final String? image;
  final bool fromNetwork;
  final double widthAndHeight;
  final double padding;

  const CustomProductImageAvatar({
    super.key,
    required this.image,
    required this.fromNetwork,
    required this.widthAndHeight,
    this.padding = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Container(
        width: widthAndHeight,
        height: widthAndHeight,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: SizedBox(
            height: 90,
            width: 90,
            child:
                image.toString() != 'null' &&
                    image.toString() != 'false' &&
                    image != null &&
                    image != ""
                ? fromNetwork
                      ? Image.network(image!, fit: BoxFit.cover)
                      : Image.memory(base64Decode(image!), fit: BoxFit.cover)
                : Image.network(EndPointsStrings.emptyImageUrl, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
