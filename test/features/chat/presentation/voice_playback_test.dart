import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/features/chat/presentation/conversation/cubit/voice_playback_cubit.dart';
import 'package:chat_app/features/chat/presentation/conversation/widgets/voice_message_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers.dart';

void main() {
  late FakeAudioEngine engine;
  late VoicePlaybackCubit cubit;

  setUp(() {
    engine = FakeAudioEngine();
    cubit = VoicePlaybackCubit(engine, FakeVoiceSourceResolver());
  });

  tearDown(() => cubit.close());

  group('VoicePlaybackCubit', () {
    test('plays the recorded file of a message', () async {
      expect(await cubit.toggle(voice('a', file: '/rec/a.m4a')), isTrue);
      expect(engine.loaded, ['/rec/a.m4a']);
      expect(engine.playing, isTrue);
      expect(cubit.state.messageId, 'a');
      expect(cubit.state.isPlaying, isTrue);
    });

    test('seed messages without a recording use a placeholder', () async {
      await cubit.toggle(voice('a'));
      expect(engine.loaded, ['placeholder:a']);
    });

    test('starting another message replaces the playing one', () async {
      await cubit.toggle(voice('a'));
      await cubit.toggle(voice('b'));
      expect(engine.loaded, ['placeholder:a', 'placeholder:b']);
      expect(cubit.state.messageId, 'b');
      expect(cubit.state.isPlaying, isTrue);
    });

    test('toggling the same message pauses and resumes', () async {
      final a = voice('a');
      await cubit.toggle(a);
      await cubit.toggle(a);
      expect(cubit.state.isPlaying, isFalse);
      expect(cubit.state.messageId, 'a', reason: 'stays loaded to resume');
      await cubit.toggle(a);
      expect(cubit.state.isPlaying, isTrue);
      expect(engine.loaded.length, 1, reason: 'no reload on resume');
    });

    test('tracks position and resets when playback completes', () async {
      await cubit.toggle(voice('a'));
      engine.emitPosition(const Duration(seconds: 5));
      expect(cubit.state.progress, closeTo(0.5, 0.001));
      engine.complete();
      expect(cubit.state.messageId, isNull);
    });

    test('switching pauses the other message and resumes it later', () async {
      final a = voice('a');
      await cubit.toggle(a);
      engine.emitPosition(const Duration(seconds: 4));

      await cubit.toggle(voice('b'));
      expect(cubit.state.messageId, 'b');
      expect(cubit.state.pausedAt, {'a': const Duration(seconds: 4)});

      engine.emitPosition(const Duration(seconds: 2));
      await cubit.toggle(a);
      expect(engine.seeks.last, const Duration(seconds: 4), reason: 'resumed');
      expect(cubit.state.position, const Duration(seconds: 4));
      expect(cubit.state.isPlaying, isTrue);
      expect(cubit.state.pausedAt, {'b': const Duration(seconds: 2)});
    });

    test('closing the chat forgets paused positions', () async {
      await cubit.toggle(voice('a'));
      engine.emitPosition(const Duration(seconds: 3));
      await cubit.toggle(voice('b'));
      await cubit.stop();
      expect(cubit.state.pausedAt, isEmpty);
      expect(cubit.state.messageId, isNull);
    });

    test('a missing recording reports failure', () async {
      expect(await cubit.toggle(voice('a', file: 'missing')), isFalse);
      expect(cubit.state.messageId, isNull);
    });
  });

  testWidgets('only one voice bubble shows as playing', (tester) async {
    // Created inside the test (not setUp) so their streams run on the
    // widget test's fake clock.
    final engine = FakeAudioEngine();
    final cubit = VoicePlaybackCubit(engine, FakeVoiceSourceResolver());
    addTearDown(cubit.close);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider.value(
          value: cubit,
          child: Scaffold(
            body: Column(
              children: [
                VoiceMessagePlayer(key: const Key('a'), message: voice('a')),
                VoiceMessagePlayer(key: const Key('b'), message: voice('b')),
              ],
            ),
          ),
        ),
      ),
    );

    Finder button(String key, String tooltip) => find.descendant(
      of: find.byKey(Key(key)),
      matching: find.byTooltip(tooltip),
    );

    await tester.tap(button('a', 'Play'));
    await tester.pump();
    expect(button('a', 'Pause'), findsOneWidget);
    engine.emitPosition(const Duration(seconds: 7));
    await tester.pump();

    await tester.tap(button('b', 'Play'));
    await tester.pump();
    expect(button('b', 'Pause'), findsOneWidget, reason: 'B plays');
    expect(button('a', 'Play'), findsOneWidget, reason: 'A paused');

    // A keeps showing where it was paused (0:07 of 0:10).
    expect(
      find.descendant(
        of: find.byKey(const Key('a')),
        matching: find.text('0:07'),
      ),
      findsOneWidget,
    );
  });
}
