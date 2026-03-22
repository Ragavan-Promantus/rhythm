import 'package:flutter/material.dart';

import 'album_art.dart';

class TrackRow extends StatelessWidget {
  const TrackRow({
    required this.title,
    required this.artistAlbum,
    required this.palette,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.onMorePressed,
    super.key,
  });

  final String title;
  final String artistAlbum;
  final List<Color> palette;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onMorePressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            AlbumArt(palette: palette, icon: icon, size: 46),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isActive
                                ? const Color(0xFF5B21F6)
                                : const Color(0xFF111827),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.graphic_eq_rounded,
                          color: Color(0xFF5B21F6),
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artistAlbum,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: onMorePressed,
              icon: const Icon(
                Icons.more_vert_rounded,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
