import 'image_picker_service.dart';

/// User-facing explanation for a failed gallery open.
String imagePickErrorText(Object error) {
  if (error is! ImagePickException) return 'Couldn’t open your gallery';
  return switch (error.kind) {
    ImagePickErrorKind.pluginNotLoaded =>
      'The photo picker isn’t loaded. Stop the app completely and run it '
          'again — hot reload/restart doesn’t load new native plugins.',
    ImagePickErrorKind.permissionDenied =>
      'Photo access is turned off. Allow it for this app in Settings to '
          'send photos.',
    ImagePickErrorKind.unknown =>
      'Couldn’t open your gallery'
          '${error.details == null ? '' : ': ${error.details}'}',
  };
}
