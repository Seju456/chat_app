import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../core/audio/voice_recorder.dart';
import '../../../domain/entities/message.dart';
import 'reply_preview.dart';

/// Composer: emoji, text, attachments, and a send button that turns into a
/// hold-to-record mic when the field is empty (slide left to cancel).
class MessageInputBar extends StatefulWidget {
  const MessageInputBar({
    super.key,
    required this.onSendText,
    required this.onSendVoice,
    required this.onPickImages,
    required this.recorder,
    this.replyingTo,
    this.onCancelReply,
  });

  final ValueChanged<String> onSendText;

  /// Called with the recording length and the recorded audio file.
  final void Function(Duration duration, String filePath) onSendVoice;
  final VoiceRecorder recorder;

  /// Opens the device gallery to pick photos.
  final VoidCallback onPickImages;
  final Message? replyingTo;
  final VoidCallback? onCancelReply;

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  static const _cancelDistance = 110.0;
  static const _minRecording = Duration(seconds: 1);
  static const _holdToRecord = Duration(milliseconds: 200);

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _stopwatch = Stopwatch();
  Timer? _ticker;
  bool _recording = false;
  double _dragDx = 0;

  /// Resolves to whether the mic actually started (permission, errors).
  Future<bool>? _starting;

  bool get _hasText => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(MessageInputBar old) {
    super.didUpdateWidget(old);
    if (widget.replyingTo != null && widget.replyingTo != old.replyingTo) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    if (_recording) widget.recorder.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSendText(text);
    _controller.clear();
  }

  void _startRecording() {
    HapticFeedback.mediumImpact();
    _stopwatch
      ..reset()
      ..start();
    _ticker = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => setState(() {}),
    );
    setState(() {
      _recording = true;
      _dragDx = 0;
    });
    // The UI starts instantly; the mic may take a moment (or be denied).
    _starting = widget.recorder.start().then(
      (granted) {
        if (!granted) {
          _abortRecording(
            'Allow microphone access in Settings to record voice messages',
          );
        }
        return granted;
      },
      onError: (Object e) {
        debugPrint('Recording failed to start: $e');
        _abortRecording('Couldn’t start recording');
        return false;
      },
    );
  }

  /// Slide left past [_cancelDistance] to discard the recording.
  void _onRecordDrag(LongPressMoveUpdateDetails d) {
    setState(() => _dragDx = d.offsetFromOrigin.dx);
    if (d.offsetFromOrigin.dx < -_cancelDistance) _stopRecording(send: false);
  }

  void _abortRecording(String message) {
    if (!mounted) return;
    _stopwatch.stop();
    _ticker?.cancel();
    setState(() => _recording = false);
    _snack(message);
  }

  Future<void> _stopRecording({required bool send}) async {
    if (!_recording) return;
    _stopwatch.stop();
    _ticker?.cancel();
    final elapsed = _stopwatch.elapsed;
    setState(() => _recording = false);

    // Released before the mic finished starting: wait for it, then decide.
    final started = await (_starting ?? Future.value(false));
    _starting = null;
    if (!started) return;

    try {
      if (!send || elapsed < _minRecording) {
        await widget.recorder.cancel();
        if (send) {
          _showHint();
        } else {
          HapticFeedback.lightImpact();
        }
        return;
      }
      final path = await widget.recorder.stop();
      if (path == null) {
        _snack('Couldn’t save the recording');
        return;
      }
      widget.onSendVoice(elapsed, path);
    } catch (e) {
      debugPrint('Recording failed to stop: $e');
      _snack('Couldn’t save the recording');
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showHint() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Hold to record, release to send'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  Future<void> _showEmojis() async {
    const emojis = [
      '😀',
      '😂',
      '😍',
      '🥰',
      '😎',
      '🤔',
      '😅',
      '😭',
      '🙏',
      '👍',
      '👏',
      '🎉',
      '🔥',
      '❤️',
      '💯',
      '✅',
      '🚀',
      '😴',
      '🤝',
      '🙌',
    ];
    final emoji = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: GridView.count(
          crossAxisCount: 8,
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          children: [
            for (final e in emojis)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => Navigator.pop(context, e),
                child: Center(
                  child: Text(e, style: const TextStyle(fontSize: 26)),
                ),
              ),
          ],
        ),
      ),
    );
    if (emoji == null) return;
    final selection = _controller.selection;
    final text = _controller.text;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    _controller.value = TextEditingValue(
      text: text.replaceRange(start, end, emoji),
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.chatColors;
    final fieldColor = theme.brightness == Brightness.dark
        ? const Color(0xFF1F2C34)
        : Colors.white;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: fieldColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 1,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSize(
                      duration: const Duration(milliseconds: 180),
                      child: widget.replyingTo == null || _recording
                          ? const SizedBox(width: double.infinity)
                          : Padding(
                              padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
                              child: ReplyPreview(
                                reply: widget.replyingTo!.toReplyInfo(),
                                isInBubble: false,
                                onClose: widget.onCancelReply,
                              ),
                            ),
                    ),
                    _recording ? _recordingRow(colors) : _textRow(colors),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            _actionButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _textRow(ChatColors colors) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      IconButton(
        tooltip: 'Emoji',
        icon: Icon(Icons.emoji_emotions_outlined, color: colors.secondaryText),
        onPressed: _showEmojis,
      ),
      Expanded(
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          minLines: 1,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: 'Message',
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
      IconButton(
        tooltip: 'Photos',
        icon: Icon(Icons.photo_library_outlined, color: colors.secondaryText),
        onPressed: widget.onPickImages,
      ),
    ],
  );

  Widget _recordingRow(ChatColors colors) {
    final cancelProgress = (-_dragDx / _cancelDistance).clamp(0.0, 1.0);
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          const SizedBox(width: 14),
          const _BlinkingDot(),
          const SizedBox(width: 10),
          Text(
            DateFormatter.duration(_stopwatch.elapsed),
            style: const TextStyle(
              fontSize: 16,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          Expanded(
            child: Opacity(
              opacity: 1 - cancelProgress,
              child: Transform.translate(
                offset: Offset(_dragDx.clamp(-_cancelDistance, 0) / 2, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chevron_left_rounded,
                      color: colors.secondaryText,
                    ),
                    Text(
                      'Slide to cancel',
                      style: TextStyle(color: colors.secondaryText),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(ThemeData theme) {
    final color = context.chatColors.unreadBadge;
    if (_hasText) {
      return _RoundButton(
        color: color,
        semanticLabel: 'Send',
        showTooltip: true,
        icon: Icons.send_rounded,
        onTap: _send,
      );
    }
    // A short-hold recognizer (WhatsApp starts almost immediately; the
    // default long press waits 500 ms).
    return RawGestureDetector(
      gestures: {
        LongPressGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
              () => LongPressGestureRecognizer(duration: _holdToRecord),
              (r) {
                r
                  ..onLongPressStart = ((_) => _startRecording())
                  ..onLongPressMoveUpdate = _onRecordDrag
                  ..onLongPressEnd = ((_) => _stopRecording(send: true));
              },
            ),
      },
      child: AnimatedScale(
        scale: _recording ? 1.35 : 1,
        duration: const Duration(milliseconds: 150),
        // No tooltip here: a Tooltip opens on long press and would claim
        // the press before the recorder above, so recording never started.
        child: _RoundButton(
          color: color,
          semanticLabel: 'Hold to record a voice message',
          icon: Icons.mic_rounded,
          onTap: _showHint,
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.color,
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.showTooltip = false,
  });

  final Color color;
  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  /// Off for buttons with their own long-press gesture (see the mic).
  final bool showTooltip;

  @override
  Widget build(BuildContext context) {
    final button = Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: 48,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(icon, key: ValueKey(icon), color: Colors.white),
            ),
          ),
        ),
      ),
    );
    return showTooltip
        ? Tooltip(message: semanticLabel, child: button)
        : button;
  }
}

class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot();

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _controller,
    child: const Icon(Icons.mic_rounded, color: Colors.redAccent),
  );
}
