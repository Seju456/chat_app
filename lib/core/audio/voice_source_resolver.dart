import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Turns a voice message into a playable local file.
abstract interface class VoiceSourceResolver {
  /// [source] is the recorded file path, or null for messages that have no
  /// recording (the demo backend's seed data).
  Future<String> resolve({
    required String messageId,
    required String? source,
    required Duration duration,
  });
}

class FileVoiceSourceResolver implements VoiceSourceResolver {
  @override
  Future<String> resolve({
    required String messageId,
    required String? source,
    required Duration duration,
  }) async {
    if (source != null && source.isNotEmpty) {
      if (!await File(source).exists()) {
        throw FileSystemException('Recording not found on this device', source);
      }
      return source;
    }
    return _placeholderFor(messageId, duration);
  }

  /// Seed messages have no audio, so a soft tone of the right length is
  /// generated once and cached.
  Future<String> _placeholderFor(String messageId, Duration duration) async {
    final dir = Directory(
      '${(await getTemporaryDirectory()).path}/voice_placeholders',
    );
    await dir.create(recursive: true);
    final file = File('${dir.path}/${messageId.hashCode.abs()}.wav');
    if (!await file.exists()) {
      final ms = duration.inMilliseconds;
      final seed = messageId.hashCode;
      final bytes = await Isolate.run(() => _toneWav(ms, seed));
      await file.writeAsBytes(bytes, flush: true);
    }
    return file.path;
  }
}

/// 8 kHz mono 16-bit WAV: short "syllables" of soft tones with pauses, so
/// it sounds speech-paced rather than a flat beep.
Uint8List _toneWav(int durationMs, int seed) {
  const rate = 8000;
  final rnd = Random(seed);
  final samples = Int16List(rate * durationMs ~/ 1000);
  var i = 0;
  while (i < samples.length) {
    final syllable = (rate * (0.12 + rnd.nextDouble() * 0.25)).toInt();
    final gap = (rate * (0.04 + rnd.nextDouble() * 0.12)).toInt();
    final freq = 180 + rnd.nextDouble() * 160;
    for (var k = 0; k < syllable && i < samples.length; k++, i++) {
      final envelope = sin(pi * k / syllable);
      final t = i / rate;
      final v = sin(2 * pi * freq * t) + 0.4 * sin(4 * pi * freq * t);
      samples[i] = (v * envelope * 6000).toInt();
    }
    i += gap;
  }
  final data = samples.buffer.asUint8List();
  final header = ByteData(44)
    ..setUint32(0, 0x52494646) // RIFF
    ..setUint32(4, 36 + data.length, Endian.little)
    ..setUint32(8, 0x57415645) // WAVE
    ..setUint32(12, 0x666d7420) // fmt
    ..setUint32(16, 16, Endian.little)
    ..setUint16(20, 1, Endian.little) // PCM
    ..setUint16(22, 1, Endian.little) // mono
    ..setUint32(24, rate, Endian.little)
    ..setUint32(28, rate * 2, Endian.little)
    ..setUint16(32, 2, Endian.little)
    ..setUint16(34, 16, Endian.little)
    ..setUint32(36, 0x64617461) // data
    ..setUint32(40, data.length, Endian.little);
  return Uint8List.fromList([...header.buffer.asUint8List(), ...data]);
}
