import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/media/image_pick_error_text.dart';
import '../../../../../core/media/image_picker_service.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/app_image.dart';
import '../../../../../core/widgets/error_view.dart';
import '../cubit/image_selection_cubit.dart';

class ImageSendResult {
  const ImageSendResult({required this.paths, this.caption});

  final List<String> paths;
  final String? caption;
}

/// WhatsApp-style review screen: swipe through the picked photos, remove
/// some, add more from the gallery, write a caption, then send.
/// Pops an [ImageSendResult], or null if cancelled.
class ImageSendPreviewPage extends StatelessWidget {
  const ImageSendPreviewPage({
    super.key,
    required this.initialPaths,
    required this.picker,
    this.recipientName,
  });

  final List<String> initialPaths;
  final ImagePickerService picker;
  final String? recipientName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ImageSelectionCubit(initialPaths),
      child: _PreviewView(picker: picker, recipientName: recipientName),
    );
  }
}

class _PreviewView extends StatefulWidget {
  const _PreviewView({required this.picker, this.recipientName});

  final ImagePickerService picker;
  final String? recipientName;

  @override
  State<_PreviewView> createState() => _PreviewViewState();
}

class _PreviewViewState extends State<_PreviewView> {
  final _pageController = PageController();
  final _caption = TextEditingController();

  ImageSelectionCubit get _cubit => context.read<ImageSelectionCubit>();

  @override
  void dispose() {
    _pageController.dispose();
    _caption.dispose();
    super.dispose();
  }

  void _jumpTo(int index) {
    if (_pageController.hasClients) _pageController.jumpToPage(index);
  }

  Future<void> _addMore() async {
    final remaining = _cubit.state.remaining;
    if (remaining <= 0) {
      context.showMessage(
        'You can send up to ${ImagePickerService.maxImages} photos at once',
      );
      return;
    }
    try {
      final picked = await widget.picker.pickFromGallery(limit: remaining);
      if (!mounted || picked.isEmpty) return;
      final dropped = _cubit.add(picked);
      _jumpTo(_cubit.state.current);
      if (dropped > 0) {
        context.showMessage(
          'Only ${ImagePickerService.maxImages} photos can be sent at once',
        );
      }
    } catch (e) {
      if (mounted) context.showMessage(imagePickErrorText(e));
    }
  }

  void _removeCurrent() {
    _cubit.removeAt(_cubit.state.current);
    if (_cubit.state.isEmpty) {
      Navigator.pop(context);
      return;
    }
    _jumpTo(_cubit.state.current);
  }

  void _send() {
    final caption = _caption.text.trim();
    Navigator.pop(
      context,
      ImageSendResult(
        paths: _cubit.state.paths,
        caption: caption.isEmpty ? null : caption,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.chatColors.unreadBadge;
    return BlocBuilder<ImageSelectionCubit, ImageSelectionState>(
      builder: (context, state) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          leading: IconButton(
            tooltip: 'Cancel',
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            state.paths.length == 1
                ? '1 photo'
                : '${state.paths.length} photos',
            style: const TextStyle(fontSize: 17),
          ),
          actions: [
            IconButton(
              tooltip: 'Remove photo',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: state.isEmpty ? null : _removeCurrent,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: state.paths.length,
                onPageChanged: _cubit.show,
                itemBuilder: (context, i) => InteractiveViewer(
                  maxScale: 4,
                  child: Center(
                    child: AppImage(
                      url: state.paths[i],
                      fit: BoxFit.contain,
                      dark: true,
                    ),
                  ),
                ),
              ),
            ),
            _ThumbnailStrip(
              state: state,
              accent: accent,
              onSelect: (i) {
                _cubit.show(i);
                _jumpTo(i);
              },
              onAdd: _addMore,
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _caption,
                        minLines: 1,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Add a caption…',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF1F2C34),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      heroTag: null,
                      tooltip: widget.recipientName == null
                          ? 'Send'
                          : 'Send to ${widget.recipientName}',
                      backgroundColor: accent,
                      onPressed: state.isEmpty ? null : _send,
                      child: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThumbnailStrip extends StatelessWidget {
  const _ThumbnailStrip({
    required this.state,
    required this.accent,
    required this.onSelect,
    required this.onAdd,
  });

  final ImageSelectionState state;
  final Color accent;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  static const _size = 56.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _size + 16,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        children: [
          Tooltip(
            message: 'Add photos',
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: _size,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white38),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_photo_alternate_outlined,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          for (var i = 0; i < state.paths.length; i++)
            GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: _size,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: i == state.current ? accent : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: AppImage(url: state.paths[i], dark: true),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
