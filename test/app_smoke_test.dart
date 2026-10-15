import 'package:chat_app/app.dart';
import 'package:chat_app/core/database/app_database.dart';
import 'package:chat_app/core/di/injection.dart';
import 'package:chat_app/core/media/image_picker_service.dart';
import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/core/widgets/highlighted_text.dart';
import 'package:chat_app/features/chat/presentation/conversation/pages/conversation_page.dart';
import 'package:chat_app/core/widgets/app_image.dart';
import 'package:chat_app/features/chat/data/datasources/fake_chat_remote_data_source.dart';
import 'package:chat_app/features/chat/presentation/conversation/widgets/image_grid.dart';
import 'package:chat_app/features/chat/presentation/conversation/widgets/message_bubble.dart';
import 'package:chat_app/features/chat/presentation/gallery/pages/image_send_preview_page.dart';
import 'package:chat_app/features/chat/presentation/chat_list/widgets/chat_tile.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/features/chat/presentation/conversation/cubit/voice_playback_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late FakeChatRemoteDataSource remote;
  late FakeImagePicker picker;

  setUp(() async {
    AppImage.useDiskCache = false;
    remote = FakeChatRemoteDataSource(
      latency: Duration.zero,
      failureRate: 0,
      backgroundTraffic: false,
    );
    await configureDependencies(
      database: AppDatabase(NativeDatabase.memory()),
      remote: remote,
      audioEngine: FakeAudioEngine(),
      voiceRecorder: FakeVoiceRecorder(),
      voiceSourceResolver: FakeVoiceSourceResolver(),
      imagePicker: picker = FakeImagePicker(),
    );
  });

  tearDown(() => sl.reset());

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  final highlighted = find.byWidgetPredicate(
    (w) => w is MessageBubble && w.isHighlighted,
  );

  /// Pumps until [finder] matches (the highlight only lasts ~1.6s).
  Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 400 && finder.evaluate().isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    remote.dispose();
    await settle(tester);
  }

  testWidgets('phone: list -> chat -> send -> archive -> search', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ChatApp());
    await settle(tester);
    expect(find.byType(ChatTile), findsWidgets);

    // Open the first chat.
    await tester.tap(find.byType(ChatTile).first);
    await settle(tester);
    expect(find.byType(MessageBubble), findsWidgets);
    expect(find.byTooltip('Voice call'), findsNothing);
    expect(find.byTooltip('Video call'), findsNothing);

    // Send a text message.
    await tester.enterText(find.byType(TextField), 'Hello from test');
    await tester.pump();
    await tester.tap(find.byTooltip('Send'));
    await settle(tester);
    expect(
      find.textContaining('Hello from test', findRichText: true),
      findsOneWidget,
    );

    // A failed gallery open explains why instead of a generic error.
    picker.error = const ImagePickException(ImagePickErrorKind.pluginNotLoaded);
    await tester.tap(find.byTooltip('Photos'));
    await settle(tester);
    expect(find.textContaining('Stop the app completely'), findsOneWidget);
    picker.error = null;
    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
        .removeCurrentSnackBar();
    await settle(tester);

    // Pick two photos from the gallery, add a caption and send.
    picker.picks.add(['p1.jpg', 'p2.jpg']);
    await tester.tap(find.byTooltip('Photos'));
    await settle(tester);
    expect(find.text('2 photos'), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byType(ImageSendPreviewPage),
        matching: find.byType(TextField),
      ),
      'Album caption',
    );
    await tester.tap(find.byTooltip(RegExp('^Send')));
    await settle(tester);
    expect(find.byType(ImageSendPreviewPage), findsNothing);
    final album = tester.widget<ImageGrid>(find.byType(ImageGrid).first);
    expect(album.urls, ['/app/p1.jpg', '/app/p2.jpg']);
    expect(
      find.textContaining('Album caption', findRichText: true),
      findsOneWidget,
    );

    // Swipe to reply on the newest bubble.
    await tester.drag(find.byType(MessageBubble).first, const Offset(120, 0));
    await settle(tester);
    expect(find.byTooltip('Cancel reply'), findsOneWidget);

    // Back to the list, archive a chat via long-press sheet.
    await tester.pageBack();
    await settle(tester);
    await tester.longPress(find.byType(ChatTile).at(1));
    await settle(tester);
    await tester.tap(find.text('Archive chat'));
    await settle(tester);
    expect(find.text('Archived'), findsOneWidget);

    // Search.
    await tester.tap(find.byTooltip('Search'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'the');
    await tester.pump(const Duration(milliseconds: 400));
    await settle(tester);
    expect(find.text('Messages'), findsOneWidget);

    // Tapping a message result opens the chat and highlights that message.
    await tester.tap(
      find
          .byWidgetPredicate((w) => w is HighlightedText && w.maxLines == 2)
          .first,
    );
    await pumpUntilFound(tester, highlighted);
    expect(highlighted, findsOneWidget);
    expect(find.byType(ConversationPage), findsOneWidget);

    await finish(tester);
  });

  testWidgets('jumps to a message hundreds of messages back', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // chat_000 has 200+ messages; m00010 is one of the oldest.
    const target = 'chat_000_m00010';
    await tester.pumpWidget(
      // Normally provided by ChatApp.
      BlocProvider.value(
        value: sl<VoicePlaybackCubit>(),
        child: MaterialApp(
          theme: AppTheme.light(),
          home: ConversationPage(
            chatId: 'chat_000',
            focus: MessageFocus(target),
          ),
        ),
      ),
    );
    await pumpUntilFound(tester, highlighted);
    final bubble = tester.widget<MessageBubble>(highlighted);
    expect(bubble.message.id, target);
    expect(
      tester
          .getRect(highlighted)
          .overlaps(tester.getRect(find.byType(ListView))),
      isTrue,
      reason: 'target is scrolled into view',
    );

    await finish(tester);
  });

  testWidgets('tablet: two-pane layout with dark theme', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const ChatApp());
    await settle(tester);
    expect(find.text('Select a chat'), findsOneWidget);

    await tester.tap(find.byType(ChatTile).at(2));
    await settle(tester);
    expect(find.byType(MessageBubble), findsWidgets);
    expect(find.byType(ChatTile), findsWidgets, reason: 'list stays visible');

    await finish(tester);
  });
}
