import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../core/widgets/error_view.dart';
import '../../../domain/entities/message.dart';
import '../cubit/voice_playback_cubit.dart';

/// Voice note UI: play/pause, seekable waveform, elapsed time, speed toggle.
/// Audio is played by the shared [VoicePlaybackCubit]; this widget only
/// renders its state, so only one message plays at a time.
class VoiceMessagePlayer extends StatefulWidget {
  const VoiceMessagePlayer({super.key, required this.message});

  final Message message;

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  final _waveKey = GlobalKey();
  late final List<double> _bars = () {
    final rnd = Random(widget.message.id.hashCode);
    return List.generate(32, (_) => 0.2 + rnd.nextDouble() * 0.8);
  }();

  VoicePlaybackCubit get _playback => context.read<VoicePlaybackCubit>();

  Future<void> _toggle() async {
    final ok = await _playback.toggle(widget.message);
    if (!ok && mounted) {
      context.showMessage('Can’t play this voice message');
    }
  }

  void _seek(Offset local) {
    final width = _waveKey.currentContext?.size?.width ?? 0;
    if (width <= 0) return;
    _playback.seek(widget.message, local.dx / width);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    final active = widget.message.isMine
        ? Theme.of(context).colorScheme.primary
        : colors.unreadBadge;
    final id = widget.message.id;
    // Only the bubble that owns the player rebuilds on position ticks.
    return BlocSelector<
      VoicePlaybackCubit,
      VoicePlaybackState,
      (VoicePlaybackState?, Duration?)
    >(
      selector: (s) => (s.messageId == id ? s : null, s.pausedAt[id]),
      builder: (context, selected) {
        final (s, pausedAt) = selected;
        final playing = s?.isPlaying ?? false;
        final loading = s?.isLoading ?? false;
        final total = (s != null && s.duration > Duration.zero)
            ? s.duration
            : widget.message.voiceDuration ?? Duration.zero;
        // Paused because another message started: keep showing its spot.
        final position = s?.position ?? pausedAt ?? Duration.zero;
        final progress =
            s?.progress ??
            (total.inMilliseconds == 0
                ? 0.0
                : (position.inMilliseconds / total.inMilliseconds).clamp(
                    0.0,
                    1.0,
                  ));
        final started = s != null && (playing || s.position > Duration.zero);
        final showPosition = started || position > Duration.zero;
        return SizedBox(
          width: 250,
          child: Row(
            children: [
              SizedBox.square(
                dimension: 48,
                child: loading
                    ? Padding(
                        padding: const EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: colors.secondaryText,
                        ),
                      )
                    : IconButton(
                        tooltip: playing ? 'Pause' : 'Play',
                        onPressed: _toggle,
                        icon: Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 34,
                          color: colors.secondaryText,
                        ),
                      ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    // No LayoutBuilder: the bubble measures its natural
                    // width, which LayoutBuilder cannot report.
                    GestureDetector(
                      key: _waveKey,
                      onTapDown: (d) => _seek(d.localPosition),
                      onHorizontalDragUpdate: (d) => _seek(d.localPosition),
                      child: CustomPaint(
                        size: const Size(double.infinity, 28),
                        painter: _WaveformPainter(
                          bars: _bars,
                          progress: progress,
                          active: active,
                          inactive: colors.secondaryText.withValues(
                            alpha: 0.45,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormatter.duration(showPosition ? position : total),
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (started)
                GestureDetector(
                  onTap: _playback.cycleSpeed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.secondaryText.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${s.speed.toString().replaceAll('.0', '')}×',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                CircleAvatar(
                  radius: 18,
                  backgroundColor: active.withValues(alpha: 0.15),
                  child: Icon(Icons.mic_rounded, color: active, size: 20),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.bars,
    required this.progress,
    required this.active,
    required this.inactive,
  });

  final List<double> bars;
  final double progress;
  final Color active;
  final Color inactive;

  @override
  void paint(Canvas canvas, Size size) {
    final gap = size.width / bars.length;
    final barWidth = gap * 0.55;
    final paint = Paint()..strokeCap = StrokeCap.round;
    for (var i = 0; i < bars.length; i++) {
      final x = i * gap + gap / 2;
      final h = bars[i] * size.height;
      paint
        ..color = (i + 0.5) / bars.length <= progress ? active : inactive
        ..strokeWidth = barWidth;
      canvas.drawLine(
        Offset(x, (size.height - h) / 2),
        Offset(x, (size.height + h) / 2),
        paint,
      );
    }
    // Playhead.
    canvas.drawCircle(
      Offset(progress * size.width, size.height / 2),
      6,
      Paint()..color = active,
    );
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.progress != progress || old.active != active;
}
