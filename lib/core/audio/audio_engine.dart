import 'dart:async';

import 'package:just_audio/just_audio.dart';

/// Minimal playback contract, so cubits and tests don't depend on a plugin.
abstract interface class AudioEngine {
  Stream<Duration> get position;

  /// Emits whether audio is playing; emits `completed` when a file ends.
  Stream<AudioEngineEvent> get events;

  /// Loads a local file and returns its duration (if known).
  Future<Duration?> load(String filePath);
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> setSpeed(double speed);
  Future<void> stop();
  Future<void> dispose();
}

enum AudioEngineEvent { playing, paused, completed }

class JustAudioEngine implements AudioEngine {
  final _player = AudioPlayer();

  @override
  Stream<Duration> get position => _player.positionStream;

  @override
  Stream<AudioEngineEvent> get events => _player.playerStateStream
      .map(
        (s) => s.processingState == ProcessingState.completed
            ? AudioEngineEvent.completed
            : s.playing
            ? AudioEngineEvent.playing
            : AudioEngineEvent.paused,
      )
      .distinct();

  @override
  Future<Duration?> load(String filePath) => _player.setFilePath(filePath);

  // just_audio's play() completes when playback ends; don't wait for that.
  @override
  Future<void> play() async => unawaited(_player.play());

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() => _player.dispose();
}
