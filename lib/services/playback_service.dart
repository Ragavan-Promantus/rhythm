import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../models/song.dart';
import 'api_service.dart';

class PlaybackService extends ChangeNotifier {
  PlaybackService._() {
    _player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _player.onPositionChanged.listen((value) {
      _position = value;
      notifyListeners();
    });

    _player.onDurationChanged.listen((value) {
      _duration = value;
      notifyListeners();
    });

    _player.onPlayerComplete.listen((_) {
      if (_canPlayNext) {
        unawaited(playNext());
        return;
      }

      _isPlaying = false;
      _position = _duration;
      notifyListeners();
    });
  }

  static final PlaybackService instance = PlaybackService._();

  final AudioPlayer _player = AudioPlayer();

  Song? _currentSong;
  List<Song> _queue = const [];
  int _currentIndex = -1;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;

  Song? get currentSong => _currentSong;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _isPlaying;
  bool get canPlayNext => _canPlayNext;
  bool get canPlayPrevious => _canPlayPrevious;

  bool get _canPlayNext =>
      _queue.isNotEmpty &&
      _currentIndex >= 0 &&
      _currentIndex < _queue.length - 1;
  bool get _canPlayPrevious => _queue.isNotEmpty && _currentIndex > 0;

  void _resetTimeline({Song? song}) {
    _position = Duration.zero;
    _duration = song?.durationSeconds != null
        ? Duration(seconds: song!.durationSeconds!)
        : Duration.zero;
    _isPlaying = false;
  }

  Future<void> playSong(
    Song song, {
    List<Song> queue = const [],
    int? index,
  }) async {
    await _player.stop();

    _queue = queue.isNotEmpty ? queue : [song];
    _currentIndex = index ?? _queue.indexWhere((item) => item.id == song.id);
    if (_currentIndex < 0) {
      _currentIndex = 0;
    }

    _currentSong = song;
    _resetTimeline(song: song);
    notifyListeners();

    await _player.play(UrlSource(ApiService.streamUrl(song.id)));
  }

  Future<void> togglePlayPause() async {
    if (_currentSong == null) {
      return;
    }

    if (_isPlaying) {
      await _player.pause();
      return;
    }

    if (_position > Duration.zero) {
      await _player.resume();
      return;
    }

    await playSong(_currentSong!, queue: _queue, index: _currentIndex);
  }

  Future<void> seekTo(Duration value) async {
    await _player.seek(value);
  }

  Future<void> playNext() async {
    if (!_canPlayNext) {
      return;
    }

    final nextIndex = _currentIndex + 1;
    await playSong(_queue[nextIndex], queue: _queue, index: nextIndex);
  }

  Future<void> playPrevious() async {
    if (!_canPlayPrevious) {
      return;
    }

    final previousIndex = _currentIndex - 1;
    await playSong(_queue[previousIndex], queue: _queue, index: previousIndex);
  }
}
