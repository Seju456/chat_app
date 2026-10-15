import 'dart:async';
import 'dart:io';

import 'package:chat_app/core/audio/audio_engine.dart';
import 'package:chat_app/core/audio/voice_recorder.dart';
import 'package:chat_app/core/audio/voice_source_resolver.dart';
import 'package:chat_app/core/media/image_picker_service.dart';
import 'package:chat_app/features/chat/domain/entities/message.dart';

Message msg(
  String id, {
  required DateTime at,
  String sender = 'a',
  String chatId = 'c1',
}) => Message(
  id: id,
  chatId: chatId,
  senderId: sender,
  senderName: sender,
  isMine: sender == Message.myUserId,
  type: MessageType.text,
  text: 'text $id',
  createdAt: at,
  status: MessageStatus.read,
);

/// In-memory [AudioEngine]: records calls and emits events like a player.
class FakeAudioEngine implements AudioEngine {
  final _position = StreamController<Duration>.broadcast(sync: true);
  final _events = StreamController<AudioEngineEvent>.broadcast(sync: true);
  final loaded = <String>[];
  Duration? loadDuration = const Duration(seconds: 10);
  bool playing = false;

  @override
  Stream<Duration> get position => _position.stream;
  @override
  Stream<AudioEngineEvent> get events => _events.stream;

  @override
  Future<Duration?> load(String filePath) async {
    loaded.add(filePath);
    return loadDuration;
  }

  @override
  Future<void> play() async {
    playing = true;
    _events.add(AudioEngineEvent.playing);
  }

  @override
  Future<void> pause() async {
    playing = false;
    _events.add(AudioEngineEvent.paused);
  }

  @override
  Future<void> stop() async {
    if (playing) await pause();
  }

  final seeks = <Duration>[];

  @override
  Future<void> seek(Duration position) async {
    seeks.add(position);
    _position.add(position);
  }

  @override
  Future<void> setSpeed(double speed) async {}

  void emitPosition(Duration p) => _position.add(p);

  void complete() {
    playing = false;
    _events.add(AudioEngineEvent.completed);
  }

  @override
  Future<void> dispose() async {
    await _position.close();
    await _events.close();
  }
}

class FakeVoiceSourceResolver implements VoiceSourceResolver {
  @override
  Future<String> resolve({
    required String messageId,
    required String? source,
    required Duration duration,
  }) async {
    if (source == 'missing') throw const FileSystemException('missing');
    return source ?? 'placeholder:$messageId';
  }
}

class FakeVoiceRecorder implements VoiceRecorder {
  bool granted = true;
  int starts = 0;
  int stops = 0;
  int cancels = 0;

  @override
  Future<bool> start() async {
    starts++;
    return granted;
  }

  @override
  Future<String?> stop() async {
    stops++;
    return '/tmp/recording.m4a';
  }

  @override
  Future<void> cancel() async => cancels++;
  @override
  Future<void> dispose() async {}
}

Message voice(String id, {String? file, bool mine = false}) => Message(
  id: id,
  chatId: 'c1',
  senderId: mine ? Message.myUserId : 'a',
  senderName: 'a',
  isMine: mine,
  type: MessageType.voice,
  mediaUrls: [?file],
  voiceDuration: const Duration(seconds: 10),
  createdAt: DateTime(2026),
  status: MessageStatus.read,
);

/// Returns queued picks in order; `persist` maps paths into "app storage".
class FakeImagePicker implements ImagePickerService {
  final picks = <List<String>>[];
  final limits = <int>[];

  /// When set, the next pick throws this.
  Object? error;

  @override
  Future<List<String>> pickFromGallery({
    int limit = ImagePickerService.maxImages,
  }) async {
    limits.add(limit);
    if (error case final e?) throw e;
    return picks.isEmpty ? const [] : picks.removeAt(0);
  }

  @override
  Future<List<String>> persist(List<String> paths) async => [
    for (final p in paths) '/app/$p',
  ];
}
