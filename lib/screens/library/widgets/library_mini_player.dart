import 'package:flutter/material.dart';

import 'album_art.dart';

class LibraryMiniPlayer extends StatelessWidget {
  const LibraryMiniPlayer({
    required this.title,
    required this.artist,
    required this.palette,
    required this.icon,
    required this.onDevicesPressed,
    required this.onPausePressed,
    super.key,
  });

  final String title;
  final String artist;
  final List<Color> palette;
  final IconData icon;
  final VoidCallback onDevicesPressed;
  final VoidCallback onPausePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          AlbumArt(palette: palette, icon: icon, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  artist,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDevicesPressed,
            icon: const Icon(
              Icons.cast_connected_rounded,
              color: Color(0xFF94A3B8),
            ),
          ),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF3EEFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: onPausePressed,
              icon: const Icon(
                Icons.pause_rounded,
                color: Color(0xFF5B21F6),
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
