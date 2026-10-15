import 'package:chat_app/core/media/image_picker_service.dart';
import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/features/chat/presentation/conversation/widgets/message_input_bar.dart';
import 'package:chat_app/features/chat/presentation/gallery/cubit/image_selection_cubit.dart';
import 'package:chat_app/features/chat/presentation/gallery/pages/image_send_preview_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers.dart';

void main() {
  group('ImageSelectionCubit', () {
    test('adds without duplicates and shows the first new photo', () {
      final cubit = ImageSelectionCubit(['a', 'b']);
      expect(cubit.add(['b', 'c', 'd']), 0);
      expect(cubit.state.paths, ['a', 'b', 'c', 'd']);
      expect(cubit.state.current, 2);
    });

    test('caps the selection at the max and reports dropped photos', () {
      final cubit = ImageSelectionCubit(
        List.generate(ImagePickerService.maxImages - 1, (i) => '$i'),
      );
      expect(cubit.add(['x', 'y', 'z']), 2);
      expect(cubit.state.paths.length, ImagePickerService.maxImages);
      expect(cubit.state.remaining, 0);
    });

    test('removing keeps a valid current photo', () {
      final cubit = ImageSelectionCubit(['a', 'b', 'c'])..show(2);
      cubit.removeAt(2);
      expect(cubit.state.paths, ['a', 'b']);
      expect(cubit.state.current, 1);
      cubit
        ..removeAt(1)
        ..removeAt(0);
      expect(cubit.state.isEmpty, isTrue);
    });
  });

  testWidgets('message bar has a Photos button and no camera', (tester) async {
    var picks = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: MessageInputBar(
            recorder: FakeVoiceRecorder(),
            onSendText: (_) {},
            onSendVoice: (_, _) {},
            onPickImages: () => picks++,
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.camera_alt_outlined), findsNothing);
    expect(find.byTooltip('Camera'), findsNothing);
    await tester.tap(find.byTooltip('Photos'));
    expect(picks, 1);
  });

  testWidgets('preview: remove, add more, caption, send', (tester) async {
    final picker = FakeImagePicker()..picks.add(['/g/d.jpg']);
    ImageSendResult? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await Navigator.push<ImageSendResult>(
                context,
                MaterialPageRoute(
                  builder: (_) => ImageSendPreviewPage(
                    initialPaths: const ['/g/a.jpg', '/g/b.jpg', '/g/c.jpg'],
                    picker: picker,
                  ),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('3 photos'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove photo'));
    await tester.pumpAndSettle();
    expect(find.text('2 photos'), findsOneWidget);

    await tester.tap(find.byTooltip('Add photos'));
    await tester.pumpAndSettle();
    expect(find.text('3 photos'), findsOneWidget);
    expect(picker.limits.single, ImagePickerService.maxImages - 2);

    await tester.enterText(find.byType(TextField), '  Beach day  ');
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();
    expect(result!.paths, ['/g/b.jpg', '/g/c.jpg', '/g/d.jpg']);
    expect(result!.caption, 'Beach day');
  });

  testWidgets('removing the last photo cancels', (tester) async {
    ImageSendResult? result;
    var closed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await Navigator.push<ImageSendResult>(
                context,
                MaterialPageRoute(
                  builder: (_) => ImageSendPreviewPage(
                    initialPaths: const ['/g/a.jpg'],
                    picker: FakeImagePicker(),
                  ),
                ),
              );
              closed = true;
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remove photo'));
    await tester.pumpAndSettle();
    expect(closed, isTrue);
    expect(result, isNull);
  });
}
