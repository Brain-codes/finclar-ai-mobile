import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'logger_service.dart';

/// Wraps `audioplayers` so the package can be swapped without touching
/// feature code — never instantiate `AudioPlayer` directly outside this file.
abstract class AudioService {
  static AudioPlayer? _player;

  /// Plays [assetPath] (relative to `assets/`, e.g. `audio/wrapped_wins.mp3`)
  /// on an infinite loop. Replaces whatever is currently playing.
  static Future<void> playLoop(String assetPath) async {
    try {
      await _player?.stop();
      await _player?.dispose();
      final player = AudioPlayer();
      _player = player;
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource(assetPath));
    } catch (e, st) {
      Log.e('AudioService.playLoop failed', error: e, stackTrace: st);
    }
  }

  /// Plays [assetPath] once, independent of [playLoop]'s shared player, so a
  /// short one-off sound effect (e.g. a chat reply chime) doesn't interrupt
  /// any looped playback that might be running elsewhere in the app.
  static Future<void> playOnce(String assetPath) async {
    try {
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.release);
      unawaited(player.onPlayerComplete.first.then((_) => player.dispose()));
      await player.play(AssetSource(assetPath));
    } catch (e, st) {
      Log.e('AudioService.playOnce failed', error: e, stackTrace: st);
    }
  }

  static Future<void> pause() async {
    try {
      await _player?.pause();
    } catch (e, st) {
      Log.e('AudioService.pause failed', error: e, stackTrace: st);
    }
  }

  static Future<void> resume() async {
    try {
      await _player?.resume();
    } catch (e, st) {
      Log.e('AudioService.resume failed', error: e, stackTrace: st);
    }
  }

  /// Stops and releases the player — call when leaving whatever screen
  /// started the loop, so the audio doesn't keep playing in the background.
  static Future<void> stop() async {
    try {
      final player = _player;
      _player = null;
      await player?.stop();
      await player?.dispose();
    } catch (e, st) {
      Log.e('AudioService.stop failed', error: e, stackTrace: st);
    }
  }
}
