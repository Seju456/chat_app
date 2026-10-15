import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/widgets/app_image.dart';
import '../../../domain/entities/message.dart';

class GalleryImage {
  const GalleryImage({
    required this.url,
    required this.heroTag,
    required this.message,
  });

  final String url;
  final String heroTag;
  final Message message;
}

/// Full-screen swipeable viewer with pinch-to-zoom and a thumbnail strip.
class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key, required this.images, this.initialIndex = 0});

  final List<GalleryImage> images;
  final int initialIndex;

  static Route<void> route({
    required List<GalleryImage> images,
    int initialIndex = 0,
  }) => PageRouteBuilder(
    opaque: false,
    barrierColor: Colors.black,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, _, _) =>
        GalleryPage(images: images, initialIndex: initialIndex),
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late final _pageController = PageController(initialPage: widget.initialIndex);
  late final _thumbController = ScrollController();
  late int _index = widget.initialIndex;
  bool _chromeVisible = true;

  @override
  void dispose() {
    _pageController.dispose();
    _thumbController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _index = index);
    if (_thumbController.hasClients) {
      _thumbController.animateTo(
        (index * 60.0 - 120).clamp(
          0,
          _thumbController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.images[_index];
    final message = current.message;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => setState(() => _chromeVisible = !_chromeVisible),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, i) => InteractiveViewer(
                maxScale: 4,
                child: Center(
                  child: Hero(
                    tag: widget.images[i].heroTag,
                    child: AppImage(
                      url: widget.images[i].url,
                      fit: BoxFit.contain,
                      showProgress: true,
                      dark: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _chromeVisible ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_chromeVisible,
              child: Column(
                children: [
                  Container(
                    color: Colors.black54,
                    child: SafeArea(
                      bottom: false,
                      child: ListTile(
                        textColor: Colors.white,
                        iconColor: Colors.white,
                        leading: IconButton(
                          tooltip: 'Close',
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                        title: Text(
                          message.isMine ? 'You' : message.senderName,
                        ),
                        subtitle: Text(
                          '${DateFormat.yMMMd().add_Hm().format(message.createdAt)}'
                          '  •  ${_index + 1} of ${widget.images.length}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if ((message.text ?? '').isNotEmpty)
                    Container(
                      width: double.infinity,
                      color: Colors.black54,
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        message.text!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  if (widget.images.length > 1)
                    Container(
                      color: Colors.black54,
                      child: SafeArea(
                        top: false,
                        child: SizedBox(
                          height: 72,
                          child: ListView.builder(
                            controller: _thumbController,
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(8),
                            itemCount: widget.images.length,
                            itemBuilder: (context, i) => GestureDetector(
                              onTap: () => _pageController.animateToPage(
                                i,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 56,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: i == _index
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Opacity(
                                    opacity: i == _index ? 1 : 0.6,
                                    child: AppImage(
                                      url: widget.images[i].url,
                                      dark: true,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
