import 'package:flutter/widgets.dart';

abstract final class Breakpoints {
  /// Above this width the app switches to a two-pane master/detail layout.
  static const double twoPane = 840;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= twoPane;
}
