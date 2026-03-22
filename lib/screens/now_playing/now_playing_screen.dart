import 'package:flutter/material.dart';

import '../../models/song.dart';
import '../../services/api_service.dart';
import '../../services/playback_service.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  String _formatDuration(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  List<Color> _paletteForSong(Song song) {
    const palettes = [
      [Color(0xFF0B1020), Color(0xFF0EA5E9), Color(0xFFEC4899)],
      [Color(0xFF1E1B4B), Color(0xFF7C3AED), Color(0xFF22D3EE)],
      [Color(0xFF111827), Color(0xFF2563EB), Color(0xFF9333EA)],
    ];

    return palettes[song.title.hashCode.abs() % palettes.length];
  }

  @override
  Widget build(BuildContext context) {
    final playback = PlaybackService.instance;

    return AnimatedBuilder(
      animation: playback,
      builder: (context, _) {
        final song = playback.currentSong;
        if (song == null) {
          return const Scaffold(body: Center(child: Text('No track selected')));
        }

        final palette = _paletteForSong(song);
        final total =
            playback.duration == Duration.zero && song.durationSeconds != null
            ? Duration(seconds: song.durationSeconds!)
            : playback.duration;
        final progress = total.inMilliseconds == 0
            ? 0.0
            : (playback.position.inMilliseconds / total.inMilliseconds).clamp(
                0.0,
                1.0,
              );
        final coverPath = song.coverImage;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  palette[0],
                  const Color(0xFF24103C),
                  const Color(0xFF1B1330),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const Expanded(
                          child: Column(
                            children: [
                              Text(
                                'PLAYING FROM',
                                style: TextStyle(
                                  color: Color(0xFFB8AFD8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Midnight Melodies Playlist',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.more_horiz_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.12),
                            Colors.white.withValues(alpha: 0.04),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          height: 180,
                          width: 180,
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x66000000),
                                blurRadius: 26,
                                offset: Offset(0, 12),
                              ),
                            ],
                            image: coverPath.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(
                                      ApiService.resolveMediaUrl(coverPath),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            gradient: coverPath.isEmpty
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: palette,
                                  )
                                : null,
                          ),
                          child: coverPath.isEmpty
                              ? const Center(
                                  child: Icon(
                                    Icons.music_note_rounded,
                                    color: Colors.white,
                                    size: 64,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                song.artist,
                                style: const TextStyle(
                                  color: Color(0xFF8B5CF6),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.favorite_rounded,
                            color: Color(0xFFC4B5FD),
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 0,
                        ),
                        overlayShape: SliderComponentShape.noOverlay,
                        activeTrackColor: const Color(0xFF7C3AED),
                        inactiveTrackColor: const Color(0xFF4B5563),
                      ),
                      child: Slider(
                        value: progress,
                        onChanged: (value) {
                          if (total == Duration.zero) {
                            return;
                          }

                          playback.seekTo(
                            Duration(
                              milliseconds: (total.inMilliseconds * value)
                                  .round(),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(playback.position),
                            style: const TextStyle(
                              color: Color(0xFFB8AFD8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatDuration(total),
                            style: const TextStyle(
                              color: Color(0xFFB8AFD8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.shuffle_rounded,
                            color: Color(0xFFC4B5FD),
                            size: 28,
                          ),
                        ),
                        IconButton(
                          onPressed: playback.canPlayPrevious
                              ? playback.playPrevious
                              : null,
                          icon: Icon(
                            Icons.skip_previous_rounded,
                            color: playback.canPlayPrevious
                                ? Colors.white
                                : Colors.white24,
                            size: 34,
                          ),
                        ),
                        Container(
                          height: 84,
                          width: 84,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x667C3AED),
                                blurRadius: 24,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: playback.togglePlayPause,
                            icon: Icon(
                              playback.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: playback.canPlayNext
                              ? playback.playNext
                              : null,
                          icon: Icon(
                            Icons.skip_next_rounded,
                            color: playback.canPlayNext
                                ? Colors.white
                                : Colors.white24,
                            size: 34,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.repeat_rounded,
                            color: Color(0xFF8B5CF6),
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(
                          Icons.speaker_group_rounded,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'AIRPODS PRO',
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.share_outlined,
                            color: Color(0xFFC4B5FD),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFF3B0A72),
                            child: Icon(
                              Icons.queue_music_rounded,
                              color: Color(0xFFC4B5FD),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Up Next: Lyrics',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_up_rounded,
                            color: Color(0xFFC4B5FD),
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
      },
    );
  }
}
