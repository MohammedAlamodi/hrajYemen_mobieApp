// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
//
// import '../../configurations/data/end_points_manager.dart';
//
// class CustomProductAvatar extends StatelessWidget {
//   final String? image;
//   final String? color;
//   final double size;
//
//   const CustomProductAvatar(
//       {super.key, required this.image, this.color, required this.size});
//
//   @override
//   Widget build(BuildContext context) {
//     return image != null &&
//             image !=
//                 '${EndPointsStrings.baseUrl}app-assets/images/icons/no-image.png'
//         ? SizedBox(
//             width: size,
//             height: size,
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8.0),
//               child: CachedNetworkImage(
//                 imageUrl: image!,
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) => const SizedBox(
//                   height: 10.0,
//                   width: 10.0,
//                   child: Center(
//                       child: CircularProgressIndicator(
//                     color: Colors.amber,
//                   )),
//                 ),
//                 errorWidget: (context, url, error) => const Icon(Icons.error),
//               ),
//             ),
//           )
//         : Container(
//             width: size,
//             height: size,
//             decoration: BoxDecoration(
//               color: color != null && color != '' && color![0] == '#'
//                   ? Color(int.parse("0xff${color?.split('#').last}"))
//                   : Colors.white,
//               borderRadius: const BorderRadius.all(Radius.circular(8)),
//             ),
//             child: const SizedBox(),
//           );
//   }
// }
