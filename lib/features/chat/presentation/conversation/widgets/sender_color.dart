import 'package:flutter/material.dart';

const _senderColors = [
  Color(0xFF1FA855),
  Color(0xFFE26B2C),
  Color(0xFF7F66FF),
  Color(0xFFD9365E),
  Color(0xFF0A9DB8),
  Color(0xFFB68B00),
  Color(0xFF02A698),
  Color(0xFFC14BD8),
];

/// Stable per-sender colour for names in group chats and reply quotes.
Color senderColor(String seed) =>
    _senderColors[seed.hashCode.abs() % _senderColors.length];
