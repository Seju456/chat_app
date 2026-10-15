import 'package:flutter/material.dart';

/// Renders [text] with every case-insensitive occurrence of [query] in bold.
class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    this.style,
    this.maxLines = 1,
  });

  final String text;
  final String query;
  final TextStyle? style;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    final highlight = base.copyWith(
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.primary,
    );
    final spans = <TextSpan>[];
    final lower = text.toLowerCase();
    final q = query.toLowerCase().trim();
    var start = 0;
    if (q.isNotEmpty) {
      var index = lower.indexOf(q);
      while (index >= 0) {
        if (index > start) {
          spans.add(TextSpan(text: text.substring(start, index)));
        }
        spans.add(
          TextSpan(
            text: text.substring(index, index + q.length),
            style: highlight,
          ),
        );
        start = index + q.length;
        index = lower.indexOf(q, start);
      }
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
    return Text.rich(
      TextSpan(style: base, children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
