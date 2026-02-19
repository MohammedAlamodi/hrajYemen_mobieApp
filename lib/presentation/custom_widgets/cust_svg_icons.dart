import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../configurations/resources/assets_manager.dart';

class CusSvgIcons extends StatelessWidget {
  final String iconAssetString;
  final double? size;
  final Color? color;
  const CusSvgIcons({super.key,required this.iconAssetString,this.size,this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: null,
      icon: SvgPicture.asset(
        iconAssetString,
        height: size ?? 20,
        width: size ?? 20,
        color: color,
      ),
    );
  }
}
