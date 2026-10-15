import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/audio/audio_engine.dart';
import '../../../../../core/audio/voice_source_resolver.dart';
import '../../../domain/entities/message.dart';

class VoicePlaybackState extends Equatable {
  const VoicePlaybackState({
    this.messageId,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1,
    this.pausedAt = const {},
  });

  /// The loaded voice message (playing or paused); null when idle.
  final String? messageId;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final double speed;

  /// Where other voice messages were paused when playback switched away
  /// from them, so they can resume from the same spot.
  final Map<String, Duration> pausedAt;

  double get progress => duration.inMilliseconds == 0
      ? 0
      : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

  VoicePlaybackState copyWith({
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    double? speed,
    Map<String, Duration>? pausedAt,
  }) => VoicePlaybackState(
    messageId: messageId,
    isPlaying: isPlaying ?? this.isPlaying,
    isLoading: isLoading ?? this.isLoading,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    speed: speed ?? this.speed,
    pausedAt: pausedAt ?? this.pausedAt,
  );

  /// Idle (nothing loaded), keeping the speed and paused positions.
  VoicePlaybackState idle() =>
      VoicePlaybackState(speed: speed, pausedAt: pausedAt);

  @override
  List<Object?> get props => [
    messageId,
    isPlaying,
    isLoading,
    position,
    duration,
    speed,
    pausedAt,
  ];
}

/// Owns the app's single audio player. Starting a voice message pauses
/// whatever was playing (remembering its position, so it resumes from the
/// same spot), so only one message can ever play at a time.
class VoicePlaybackCubit extends Cubit<VoicePlaybackState> {
  VoicePlaybackCubit(this._engine, this._resolver)
    : super(const VoicePlaybackState()) {
    _positionSub = _engine.position.listen((p) {
      if (state.messageId != null && !state.isLoading) {
        emit(state.copyWith(position: p));
      }
    });
    _eventSub = _engine.events.listen(_onEngineEvent);
  }

  static const speeds = [1.0, 1.5, 2.0];

  final AudioEngine _engine;
  final VoiceSourceResolver _resolver;
  late final StreamSubscription<Duration> _positionSub;
  late final StreamSubscription<AudioEngineEvent> _eventSub;

  /// Bumped on every load so a slow load can't override a newer tap.
  int _loadToken = 0;

  /// Play/pause [message]. Returns false if its audio can't be played.
  Future<bool> toggle(Message message) async {
    if (state.messageId == message.id && !state.isLoading) {
      if (state.isPlaying) {
        await _engine.pause();
      } else {
        await _engine.play();
      }
      return true;
    }
    return _load(message, autoplay: true);
  }

  /// Seeks [message] to [fraction] of its length, loading it if needed.
  Future<void> seek(Message message, double fraction) async {
    if (state.messageId != message.id) {
      if (!await _load(message, autoplay: false)) return;
    }
    final target = state.duration * fraction.clamp(0.0, 1.0);
    emit(state.copyWith(position: target));
    await _engine.seek(target);
  }

  Future<void> cycleSpeed() async {
    final next = speeds[(speeds.indexOf(state.speed) + 1) % speeds.length];
    emit(state.copyWith(speed: next));
    await _engine.setSpeed(next);
  }

  /// Stops playback and forgets paused positions (the chat was closed).
  Future<void> stop() async {
    _loadToken++;
    emit(VoicePlaybackState(speed: state.speed));
    await _engine.stop();
  }

  Future<bool> _load(Message message, {required bool autoplay}) async {
    final token = ++_loadToken;
    final fallback = message.voiceDuration ?? Duration.zero;

    // Pause the current message: remember where it was.
    final pausedAt = {...state.pausedAt};
    final previous = state.messageId;
    if (previous != null &&
        previous != message.id &&
        state.position > Duration.zero) {
      pausedAt[previous] = state.position;
    }
    final resumeAt = pausedAt.remove(message.id) ?? Duration.zero;

    emit(
      VoicePlaybackState(
        messageId: message.id,
        isLoading: true,
        position: resumeAt,
        duration: fallback,
        speed: state.speed,
        pausedAt: pausedAt,
      ),
    );
    try {
      await _engine.stop();
      final path = await _resolver.resolve(
        messageId: message.id,
        source: message.mediaUrls.firstOrNull,
        duration: fallback,
      );
      if (token != _loadToken) return true;
      final duration = await _engine.load(path);
      if (token != _loadToken) return true;
      await _engine.setSpeed(state.speed);
      if (resumeAt > Duration.zero) await _engine.seek(resumeAt);
      emit(
        state.copyWith(
          isLoading: false,
          duration: duration ?? fallback,
          position: resumeAt,
        ),
      );
      if (autoplay) await _engine.play();
      return true;
    } catch (e) {
      debugPrint('Voice playback failed: $e');
      if (token == _loadToken) emit(state.idle());
      return false;
    }
  }

  void _onEngineEvent(AudioEngineEvent event) {
    if (state.messageId == null) return;
    switch (event) {
      case AudioEngineEvent.playing:
        emit(state.copyWith(isPlaying: true));
      case AudioEngineEvent.paused:
        emit(state.copyWith(isPlaying: false));
      case AudioEngineEvent.completed:
        // Back to the start, ready to replay, like WhatsApp.
        emit(state.idle());
        _engine.stop();
    }
  }

  @override
  Future<void> close() async {
    await _positionSub.cancel();
    await _eventSub.cancel();
    await _engine.dispose();
    return super.close();
  }
}
