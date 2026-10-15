import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Initials avatar with optional online dot and selection check.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    required this.color,
    this.size = 48,
    this.isGroup = false,
    this.isOnline = false,
    this.isSelected = false,
  });

  final String name;
  final int color;
  final double size;
  final bool isGroup;
  final bool isOnline;
  final bool isSelected;

  String get _initials {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty && RegExp(r'[A-Za-z]').hasMatch(p[0]))
        .toList();
    if (parts.isEmpty) return name.isEmpty ? '?' : name.characters.first;
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: size / 2,
            backgroundColor: Color(color),
            child: isGroup
                ? Icon(
                    Icons.groups_rounded,
                    color: Colors.white,
                    size: size * 0.55,
                  )
                : Text(
                    _initials,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: size * 0.36,
                    ),
                  ),
          ),
          if (isOnline && !isSelected)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  color: colors.unreadBadge,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
              ),
            ),
          Positioned(
            right: -2,
            bottom: -2,
            child: AnimatedScale(
              scale: isSelected ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.unreadBadge,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: Icon(Icons.check, size: size * 0.3, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
