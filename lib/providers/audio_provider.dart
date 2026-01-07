import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioManager {
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  
  bool _musicEnabled = true;
  bool _sfxEnabled = true;

  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;

  Future<void> playBackgroundMusic(String assetPath) async {
    if (!_musicEnabled) return;
    await _musicPlayer.play(AssetSource(assetPath));
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
  }

  Future<void> playSfx(String assetPath) async {
    if (!_sfxEnabled) return;
    await _sfxPlayer.play(AssetSource(assetPath));
  }

  void toggleMusic(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      _musicPlayer.pause();
    } else {
      _musicPlayer.resume();
    }
  }

  void toggleSfx(bool enabled) {
    _sfxEnabled = enabled;
  }

  void dispose() {
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
  }
}

final audioManagerProvider = Provider<AudioManager>((ref) {
  final manager = AudioManager();
  ref.onDispose(() => manager.dispose());
  return manager;
});