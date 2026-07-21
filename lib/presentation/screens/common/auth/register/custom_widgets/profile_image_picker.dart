import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ye_hraj/configurations/resources/app_colors.dart';

/// ودجت اختيار/عرض الصورة الشخصية في شاشة التسجيل والتعديل.
class ProfileImagePicker extends StatelessWidget {
  final File? personalPhoto;
  final String? existingImageUrl;
  final VoidCallback onTap;

  const ProfileImagePicker({
    super.key,
    required this.onTap,
    this.personalPhoto,
    this.existingImageUrl,
  });

  bool get _hasExistingImage =>
      existingImageUrl != null && existingImageUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final bool showPlaceholder = personalPhoto == null && !_hasExistingImage;

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE1E8EF),
                shape: BoxShape.circle,
                image: personalPhoto != null
                    ? DecorationImage(
                        image: FileImage(personalPhoto!),
                        fit: BoxFit.cover,
                      )
                    : _hasExistingImage
                        ? DecorationImage(
                            image: NetworkImage(existingImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
              ),
              child: showPlaceholder
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.current.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
