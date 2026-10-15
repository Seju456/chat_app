import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Image from a URL (disk-cached) or a local file path (photos the user
/// sent), with a neutral placeholder and an error state.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.showProgress = false,
    this.dark = false,
  });

  /// Disk caching relies on native plugins; tests switch it off.
  @visibleForTesting
  static bool useDiskCache = true;

  /// An http(s) URL or a local file path.
  final String url;

  static bool isRemote(String source) =>
      source.startsWith('http://') || source.startsWith('https://');
  final BoxFit fit;
  final bool showProgress;

  /// Use light-on-dark placeholders (e.g. the full-screen gallery).
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final tint = dark
        ? Colors.white12
        : context.chatColors.secondaryText.withValues(alpha: 0.15);
    final placeholder = ColoredBox(
      color: tint,
      child: showProgress
          ? Center(
              child: SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: dark ? Colors.white : null,
                ),
              ),
            )
          : null,
    );
    final error = ColoredBox(
      color: tint,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: dark ? Colors.white54 : context.chatColors.secondaryText,
        ),
      ),
    );
    if (!isRemote(url)) {
      return Image.file(
        File(url),
        fit: fit,
        errorBuilder: (_, _, _) => error,
        frameBuilder: (_, child, frame, sync) =>
            sync || frame != null ? child : placeholder,
      );
    }
    if (!useDiskCache) {
      return Image.network(
        url,
        fit: fit,
        errorBuilder: (_, _, _) => error,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : placeholder,
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) => error,
    );
  }
}
