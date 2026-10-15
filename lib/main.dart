import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'features/settings/presentation/theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await sl<ThemeCubit>().load();
  runApp(const ChatApp());
}
