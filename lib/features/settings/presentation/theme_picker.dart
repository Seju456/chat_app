import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/settings_repository.dart';
import 'theme_cubit.dart';

Future<void> showThemePicker(BuildContext context) {
  final cubit = context.read<ThemeCubit>();
  final current = switch (cubit.state) {
    ThemeMode.system => AppThemeMode.system,
    ThemeMode.light => AppThemeMode.light,
    ThemeMode.dark => AppThemeMode.dark,
  };
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      title: const Text('Choose theme'),
      children: [
        for (final (mode, label, icon) in const [
          (
            AppThemeMode.system,
            'System default',
            Icons.brightness_auto_rounded,
          ),
          (AppThemeMode.light, 'Light', Icons.light_mode_rounded),
          (AppThemeMode.dark, 'Dark', Icons.dark_mode_rounded),
        ])
          ListTile(
            leading: Icon(icon),
            title: Text(label),
            trailing: mode == current
                ? Icon(
                    Icons.check_rounded,
                    color: Theme.of(dialogContext).colorScheme.primary,
                  )
                : null,
            onTap: () {
              cubit.setMode(mode);
              Navigator.pop(dialogContext);
            },
          ),
      ],
    ),
  );
}
