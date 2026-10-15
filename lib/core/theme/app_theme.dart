import 'package:flutter/material.dart';

/// Chat-specific colours that are not covered by [ColorScheme].
@immutable
class ChatColors extends ThemeExtension<ChatColors> {
  const ChatColors({
    required this.outgoingBubble,
    required this.incomingBubble,
    required this.chatBackground,
    required this.dateChip,
    required this.readTick,
    required this.unreadBadge,
    required this.secondaryText,
    required this.selectionOverlay,
    required this.highlight,
  });

  final Color outgoingBubble;
  final Color incomingBubble;
  final Color chatBackground;
  final Color dateChip;
  final Color readTick;
  final Color unreadBadge;
  final Color secondaryText;
  final Color selectionOverlay;
  final Color highlight;

  static const light = ChatColors(
    outgoingBubble: Color(0xFFD9FDD3),
    incomingBubble: Colors.white,
    chatBackground: Color(0xFFEFEAE2),
    dateChip: Color(0xFFFFFFFF),
    readTick: Color(0xFF53BDEB),
    unreadBadge: Color(0xFF25D366),
    secondaryText: Color(0xFF667781),
    selectionOverlay: Color(0x3325D366),
    highlight: Color(0x6625D366),
  );

  static const dark = ChatColors(
    outgoingBubble: Color(0xFF005C4B),
    incomingBubble: Color(0xFF202C33),
    chatBackground: Color(0xFF0B141A),
    dateChip: Color(0xFF182229),
    readTick: Color(0xFF53BDEB),
    unreadBadge: Color(0xFF00A884),
    secondaryText: Color(0xFF8696A0),
    selectionOverlay: Color(0x3300A884),
    highlight: Color(0x6600A884),
  );

  @override
  ChatColors copyWith() => this;

  @override
  ChatColors lerp(ChatColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return ChatColors(
      outgoingBubble: l(outgoingBubble, other.outgoingBubble),
      incomingBubble: l(incomingBubble, other.incomingBubble),
      chatBackground: l(chatBackground, other.chatBackground),
      dateChip: l(dateChip, other.dateChip),
      readTick: l(readTick, other.readTick),
      unreadBadge: l(unreadBadge, other.unreadBadge),
      secondaryText: l(secondaryText, other.secondaryText),
      selectionOverlay: l(selectionOverlay, other.selectionOverlay),
      highlight: l(highlight, other.highlight),
    );
  }
}

extension ChatThemeX on BuildContext {
  ChatColors get chatColors => Theme.of(this).extension<ChatColors>()!;
}

abstract final class AppTheme {
  static const _brand = Color(0xFF008069);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: _brand).copyWith(
      primary: _brand,
      secondary: const Color(0xFF25D366),
      surface: Colors.white,
    );
    return _base(scheme, ChatColors.light).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111B21),
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
    );
  }

  static ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: _brand,
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF00A884),
          secondary: const Color(0xFF00A884),
          surface: const Color(0xFF111B21),
          onSurface: const Color(0xFFE9EDEF),
        );
    return _base(scheme, ChatColors.dark).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F2C34),
        foregroundColor: Color(0xFFE9EDEF),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }

  static ThemeData _base(ColorScheme scheme, ChatColors chat) => ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    extensions: [chat],
    dividerTheme: DividerThemeData(
      color: chat.secondaryText.withValues(alpha: 0.15),
      space: 1,
      thickness: 0.5,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: chat.unreadBadge,
      foregroundColor: Colors.white,
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    listTileTheme: ListTileThemeData(iconColor: chat.secondaryText),
  );
}
