import 'package:flutter/material.dart';

import 'widgets/bottom_nav_item.dart';
import 'widgets/library_mini_player.dart';
import 'widgets/round_icon_button.dart';
import 'widgets/track_row.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  static const _tabs = ['Playlists', 'Artists', 'Albums', 'Songs', 'Podcasts'];

  final List<_LibraryTrack> _tracks = const [
    _LibraryTrack(
      title: 'Midnight City',
      artistAlbum: 'M83 • Hurry Up, We\'re Dreaming',
      palette: [Color(0xFF7EE7E3), Color(0xFF4F46E5), Color(0xFFFF7A59)],
      icon: Icons.waves_rounded,
    ),
    _LibraryTrack(
      title: 'Levitating',
      artistAlbum: 'Dua Lipa • Future Nostalgia',
      palette: [Color(0xFF0F172A), Color(0xFF1D4ED8), Color(0xFFF59E0B)],
      icon: Icons.graphic_eq_rounded,
    ),
    _LibraryTrack(
      title: 'Blinding Lights',
      artistAlbum: 'The Weeknd • After Hours',
      palette: [Color(0xFF0F172A), Color(0xFF7C3AED), Color(0xFF22D3EE)],
      icon: Icons.bolt_rounded,
    ),
    _LibraryTrack(
      title: 'Starboy',
      artistAlbum: 'The Weeknd • Starboy',
      palette: [Color(0xFF04131D), Color(0xFF0F766E), Color(0xFF8B5CF6)],
      icon: Icons.nightlife_rounded,
      isActive: true,
    ),
    _LibraryTrack(
      title: 'Save Your Tears',
      artistAlbum: 'The Weeknd • After Hours',
      palette: [Color(0xFF111827), Color(0xFF7C2D12), Color(0xFFDB2777)],
      icon: Icons.album_rounded,
    ),
    _LibraryTrack(
      title: 'Heat Waves',
      artistAlbum: 'Glass Animals • Dreamland',
      palette: [Color(0xFF1F2937), Color(0xFF64748B), Color(0xFFB45309)],
      icon: Icons.equalizer_rounded,
    ),
    _LibraryTrack(
      title: 'Good 4 U',
      artistAlbum: 'Olivia Rodrigo • SOUR',
      palette: [Color(0xFFF8FAFC), Color(0xFFE5E7EB), Color(0xFFD6D3D1)],
      icon: Icons.music_note_rounded,
    ),
  ];

  int _selectedTab = 0;
  int _selectedNav = 2;

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1F2937),
          content: Text(text),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final activeTrack = _tracks.firstWhere((track) => track.isActive);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFCFF), Color(0xFFF1F4FF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Library',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                          letterSpacing: -0.9,
                        ),
                      ),
                    ),
                    RoundIconButton(
                      icon: Icons.search_rounded,
                      onPressed: () => _showMessage('Search is coming soon.'),
                    ),
                    const SizedBox(width: 10),
                    RoundIconButton(
                      icon: Icons.settings_outlined,
                      onPressed: () => _showMessage('Settings is coming soon.'),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tabs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 20),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedTab == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTab = index;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _tabs[index],
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF5B21F6)
                                    : const Color(0xFF94A3B8),
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              height: 6,
                              width: 6,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF5B21F6)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: ListView.separated(
                    itemCount: _tracks.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      final track = _tracks[index];
                      return TrackRow(
                        title: track.title,
                        artistAlbum: track.artistAlbum,
                        palette: track.palette,
                        icon: track.icon,
                        isActive: track.isActive,
                        onMorePressed: () =>
                            _showMessage('More actions for ${track.title}.'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                LibraryMiniPlayer(
                  title: activeTrack.title,
                  artist: activeTrack.artistAlbum.split(' • ').first,
                  palette: activeTrack.palette,
                  icon: activeTrack.icon,
                  onDevicesPressed: () => _showMessage('Devices coming soon.'),
                  onPausePressed: () => _showMessage('Playback paused.'),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F0F172A),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      BottomNavItem(
                        icon: Icons.home_outlined,
                        label: 'Home',
                        isSelected: _selectedNav == 0,
                        onTap: () {
                          setState(() {
                            _selectedNav = 0;
                          });
                        },
                      ),
                      BottomNavItem(
                        icon: Icons.explore_outlined,
                        label: 'Explore',
                        isSelected: _selectedNav == 1,
                        onTap: () {
                          setState(() {
                            _selectedNav = 1;
                          });
                        },
                      ),
                      BottomNavItem(
                        icon: Icons.library_music_outlined,
                        label: 'Library',
                        isSelected: _selectedNav == 2,
                        onTap: () {
                          setState(() {
                            _selectedNav = 2;
                          });
                        },
                      ),
                      BottomNavItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Profile',
                        isSelected: _selectedNav == 3,
                        onTap: () {
                          setState(() {
                            _selectedNav = 3;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LibraryTrack {
  const _LibraryTrack({
    required this.title,
    required this.artistAlbum,
    required this.palette,
    required this.icon,
    this.isActive = false,
  });

  final String title;
  final String artistAlbum;
  final List<Color> palette;
  final IconData icon;
  final bool isActive;
}
