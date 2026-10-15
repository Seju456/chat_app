import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_image.dart';

/// WhatsApp-style album: 1 image full, 2–4 in a grid, "+N" on the 4th tile.
class ImageGrid extends StatelessWidget {
  const ImageGrid({
    super.key,
    required this.urls,
    required this.heroPrefix,
    required this.onOpen,
  });

  final List<String> urls;
  final String heroPrefix;
  final ValueChanged<int> onOpen;

  static const width = 260.0;

  @override
  Widget build(BuildContext context) {
    if (urls.length == 1) {
      return SizedBox(width: width, height: width, child: _tile(context, 0));
    }
    final shown = urls.length >= 4 ? 4 : urls.length;
    const gap = 3.0;
    const half = (width - gap) / 2;
    final tiles = [
      for (var i = 0; i < shown; i++)
        SizedBox(
          width: shown == 3 && i == 0 ? width : half,
          height: shown == 2 ? width * 0.75 : half,
          child: _tile(context, i, more: i == 3 ? urls.length - 4 : 0),
        ),
    ];
    return SizedBox(
      width: width,
      child: Wrap(spacing: gap, runSpacing: gap, children: tiles),
    );
  }

  Widget _tile(BuildContext context, int index, {int more = 0}) {
    return GestureDetector(
      onTap: () => onOpen(index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: '$heroPrefix-$index',
              child: AppImage(url: urls[index], showProgress: true),
            ),
            if (more > 0)
              ColoredBox(
                color: Colors.black54,
                child: Center(
                  child: Text(
                    '+$more',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
