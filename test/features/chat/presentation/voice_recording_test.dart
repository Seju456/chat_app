import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/features/chat/presentation/conversation/widgets/message_input_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers.dart';

void main() {
  late FakeVoiceRecorder recorder;
  late List<(Duration, String)> sent;

  setUp(() {
    recorder = FakeVoiceRecorder();
    sent = [];
  });

  Future<void> pumpBar(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: MessageInputBar(
            recorder: recorder,
            onSendText: (_) {},
            onPickImages: () {},
            onSendVoice: (d, path) => sent.add((d, path)),
          ),
        ),
      ),
    ),
  );

  Finder mic() => find.byIcon(Icons.mic_rounded);

  /// The recorder's timer uses a real Stopwatch, so wait in real time.
  Future<void> hold(WidgetTester tester, Duration d) async {
    await tester.pump(const Duration(milliseconds: 300));
    await tester.runAsync(() => Future<void>.delayed(d));
    await tester.pump();
  }

  testWidgets('holding the mic records and sends a voice message', (
    tester,
  ) async {
    await pumpBar(tester);
    final gesture = await tester.startGesture(tester.getCenter(mic()));
    await hold(tester, const Duration(milliseconds: 1200));
    expect(recorder.starts, 1, reason: 'recording started');
    expect(find.text('Slide to cancel'), findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(recorder.stops, 1);
    expect(sent.single.$2, '/tmp/recording.m4a');
    expect(sent.single.$1, greaterThanOrEqualTo(const Duration(seconds: 1)));
  });

  testWidgets('a quick tap only shows the hint', (tester) async {
    await pumpBar(tester);
    await tester.tap(mic());
    await tester.pump();
    expect(recorder.starts, 0);
    expect(find.text('Hold to record, release to send'), findsOneWidget);
  });

  testWidgets('sliding left cancels the recording', (tester) async {
    await pumpBar(tester);
    final gesture = await tester.startGesture(tester.getCenter(mic()));
    await hold(tester, const Duration(milliseconds: 1200));
    await gesture.moveBy(const Offset(-160, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(recorder.cancels, 1);
    expect(sent, isEmpty);
  });

  testWidgets('denied microphone permission explains what to do', (
    tester,
  ) async {
    recorder.granted = false;
    await pumpBar(tester);
    final gesture = await tester.startGesture(tester.getCenter(mic()));
    await hold(tester, const Duration(milliseconds: 100));
    expect(find.textContaining('Allow microphone access'), findsOneWidget);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(sent, isEmpty);
  });
}
