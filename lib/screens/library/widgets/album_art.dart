import 'package:flutter/material.dart';

import '../../../services/api_service.dart';

class AlbumArt extends StatelessWidget {
  const AlbumArt({
    required this.palette,
    required this.icon,
    required this.size,
    this.imagePath = '',
    super.key,
  });

  final List<Color> palette;
  final IconData icon;
  final double size;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath.isNotEmpty;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: hasImage
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: palette,
              ),
        image: hasImage
            ? DecorationImage(
                image: NetworkImage(ApiService.resolveMediaUrl(imagePath)),
                fit: BoxFit.cover,
              )
            : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: hasImage
            ? null
            : Icon(
                icon,
                color: Colors.white.withValues(alpha: 0.9),
                size: size * 0.45,
              ),
      ),
    );
  }
}
