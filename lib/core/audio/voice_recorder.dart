import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

abstract interface class VoiceRecorder {
  /// Starts recording. Returns false if microphone access is denied.
  Future<bool> start();

  /// Stops and returns the recorded file path (null if nothing recorded).
  Future<String?> stop();

  /// Stops and deletes the recording.
  Future<void> cancel();

  Future<void> dispose();
}

class MicVoiceRecorder implements VoiceRecorder {
  final _recorder = AudioRecorder();

  @override
  Future<bool> start() async {
    if (!await _recorder.hasPermission()) return false;
    final dir = Directory(
      '${(await getApplicationDocumentsDirectory()).path}/voice_notes',
    );
    await dir.create(recursive: true);
    final path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, numChannels: 1),
      path: path,
    );
    return true;
  }

  @override
  Future<String?> stop() => _recorder.stop();

  @override
  Future<void> cancel() => _recorder.cancel();

  @override
  Future<void> dispose() => _recorder.dispose();
}
