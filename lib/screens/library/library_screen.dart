import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/app_user.dart';
import '../../models/song.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../login/login_screen.dart';
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

  int _selectedTab = 0;
  int _selectedNav = 2;
  bool _isLoading = true;
  AppUser? _user;
  List<Song> _songs = const [];

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

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

  Future<void> _loadLibrary() async {
    try {
      final user = await SessionService.readUser();
      final songs = await ApiService.fetchSongs();

      if (!mounted) {
        return;
      }

      setState(() {
        _user = user;
        _songs = songs;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _user = null;
        _songs = const [];
        _isLoading = false;
      });
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
      _showMessage(
        'Unable to load songs from ${ApiService.baseUrl}. On a real phone, point API_BASE_URL to your computer LAN IP.',
      );
    }
  }

  Future<void> _logout() async {
    await SessionService.clearSession();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _openSongUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    if (mounted) {
      _showMessage('Could not open $url');
    }
  }

  Future<void> _showSongActions(Song song) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${song.artist} • ${song.album}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.play_circle_fill_rounded),
                  title: const Text('Stream song'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openSongUrl(ApiService.streamUrl(song.id));
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.download_rounded),
                  title: const Text('Download song'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openSongUrl(ApiService.downloadUrl(song.id));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Color> _paletteForSong(Song song) {
    const palettes = [
      [Color(0xFF7EE7E3), Color(0xFF4F46E5), Color(0xFFFF7A59)],
      [Color(0xFF0F172A), Color(0xFF1D4ED8), Color(0xFFF59E0B)],
      [Color(0xFF04131D), Color(0xFF0F766E), Color(0xFF8B5CF6)],
      [Color(0xFF111827), Color(0xFF7C2D12), Color(0xFFDB2777)],
      [Color(0xFF1F2937), Color(0xFF64748B), Color(0xFFB45309)],
    ];

    return palettes[song.title.hashCode.abs() % palettes.length];
  }

  IconData _iconForSong(Song song) {
    const icons = [
      Icons.music_note_rounded,
      Icons.graphic_eq_rounded,
      Icons.album_rounded,
      Icons.equalizer_rounded,
      Icons.waves_rounded,
    ];

    return icons[song.artist.hashCode.abs() % icons.length];
  }

  @override
  Widget build(BuildContext context) {
    final activeSong = _songs.isNotEmpty ? _songs.first : null;

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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Library',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                              letterSpacing: -0.9,
                            ),
                          ),
                          if (_user != null)
                            Text(
                              'Signed in as ${_user!.name}',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    RoundIconButton(
                      icon: Icons.search_rounded,
                      onPressed: () => _showMessage(
                        _isLoading
                            ? 'Library is still loading.'
                            : 'Backend search is not available yet.',
                      ),
                    ),
                    const SizedBox(width: 10),
                    RoundIconButton(
                      icon: Icons.logout_rounded,
                      onPressed: _logout,
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _songs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.library_music_outlined,
                                size: 44,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'No songs found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Your backend returned an empty library.',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 18),
                              FilledButton.tonal(
                                onPressed: () {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  _loadLibrary();
                                },
                                child: const Text('Refresh'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadLibrary,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _songs.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 18),
                            itemBuilder: (context, index) {
                              final song = _songs[index];
                              return TrackRow(
                                title: song.title,
                                artistAlbum: '${song.artist} • ${song.album}',
                                palette: _paletteForSong(song),
                                icon: _iconForSong(song),
                                isActive: index == 0,
                                onMorePressed: () => _showSongActions(song),
                              );
                            },
                          ),
                        ),
                ),
                const SizedBox(height: 14),
                if (activeSong != null)
                  LibraryMiniPlayer(
                    title: activeSong.title,
                    artist: activeSong.artist,
                    palette: _paletteForSong(activeSong),
                    icon: _iconForSong(activeSong),
                    onDevicesPressed: () =>
                        _showMessage('Device handoff is not available yet.'),
                    onPausePressed: () =>
                        _openSongUrl(ApiService.streamUrl(activeSong.id)),
                  ),
                if (activeSong != null) const SizedBox(height: 10),
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
