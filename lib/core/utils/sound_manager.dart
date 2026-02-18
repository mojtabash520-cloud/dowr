import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool isMusicMuted = false;
  bool _isPlaying = false;

  Future<void> startMusic({bool forceRestart = false}) async {
    if (isMusicMuted) return;
    if (_isPlaying && !forceRestart) return;

    try {
      await _musicPlayer.stop();
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(0.3);
      await _musicPlayer.play(AssetSource('audio/music.mp3'));
      _isPlaying = true;
    } catch (e) {}
  }

  void stopMusic() {
    _musicPlayer.stop();
    _isPlaying = false;
  }

  void pauseMusic() {
    if (_isPlaying) _musicPlayer.pause();
  }

  void resumeMusic() {
    if (!isMusicMuted && _isPlaying) _musicPlayer.resume();
  }

  void toggleMute() {
    isMusicMuted = !isMusicMuted;
    if (isMusicMuted) {
      _musicPlayer.pause();
    } else {
      _musicPlayer.resume();
    }
  }

  Future<void> _playLocal(String fileName) async {
    try {
      if (_sfxPlayer.state == PlayerState.playing) await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/$fileName'));
    } catch (e) {}
  }

  void playCorrect() {
    _playLocal('correct.mp3');
    HapticFeedback.lightImpact();
  }

  void playFoul() {
    _playLocal('wrong.mp3');
    HapticFeedback.heavyImpact();
  }

  void playPass() {
    _playLocal('pass.mp3');
    HapticFeedback.mediumImpact();
  }

  void playTick() {
    _playLocal('tick.mp3');
  }

  void playGameOver() {
    stopMusic();
    _playLocal('finish.mp3');
  }
}
