import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

enum ImagePickErrorKind {
  /// The native picker isn't in the running app (added since the last full
  /// build; hot reload/restart doesn't load native code).
  pluginNotLoaded,

  /// The user denied photo library access.
  permissionDenied,
  unknown,
}

/// Why the gallery couldn't be opened, so the UI can say something useful.
class ImagePickException implements Exception {
  const ImagePickException(this.kind, [this.details]);

  final ImagePickErrorKind kind;
  final String? details;

  @override
  String toString() => 'ImagePickException($kind, $details)';
}

abstract interface class ImagePickerService {
  /// Max photos per message, like WhatsApp.
  static const maxImages = 30;

  /// Opens the device gallery with multi-select. Returns temporary file
  /// paths (empty if the user cancelled). Throws [ImagePickException].
  Future<List<String>> pickFromGallery({int limit = maxImages});

  /// Copies picked images into app storage so they survive cache clean-up.
  /// Call only when the user actually sends.
  Future<List<String>> persist(List<String> paths);
}

class DeviceImagePickerService implements ImagePickerService {
  final _picker = ImagePicker();

  @override
  Future<List<String>> pickFromGallery({
    int limit = ImagePickerService.maxImages,
  }) async {
    if (limit < 1) return const [];
    try {
      return await _pick(limit);
    } on MissingPluginException catch (e) {
      debugPrint('Image picker plugin missing: $e');
      throw const ImagePickException(ImagePickErrorKind.pluginNotLoaded);
    } on PlatformException catch (e) {
      debugPrint('Image picker failed: ${e.code} ${e.message}');
      switch (e.code) {
        case 'already_active': // A second tap while the picker is open.
          return const [];
        case 'photo_access_denied':
        case 'photo_access_restricted':
          throw ImagePickException(
            ImagePickErrorKind.permissionDenied,
            e.message,
          );
        default:
          throw ImagePickException(
            ImagePickErrorKind.unknown,
            e.message ?? e.code,
          );
      }
    } catch (e) {
      debugPrint('Image picker failed: $e');
      throw ImagePickException(ImagePickErrorKind.unknown, '$e');
    }
  }

  Future<List<String>> _pick(int limit) async {
    // Downscale/compress like a chat app does, to keep messages light.
    final files = limit == 1
        ? [
            ?await _picker.pickImage(
              source: ImageSource.gallery,
              maxWidth: 2048,
              maxHeight: 2048,
              imageQuality: 85,
            ),
          ]
        : await _picker.pickMultiImage(
            maxWidth: 2048,
            maxHeight: 2048,
            imageQuality: 85,
            limit: limit,
          );
    return files.map((f) => f.path).toList();
  }

  @override
  Future<List<String>> persist(List<String> paths) async {
    final dir = Directory(
      '${(await getApplicationDocumentsDirectory()).path}/chat_images',
    );
    await dir.create(recursive: true);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return [
      for (var i = 0; i < paths.length; i++)
        (await File(
          paths[i],
        ).copy('${dir.path}/${stamp}_$i${_extension(paths[i])}')).path,
    ];
  }

  static String _extension(String path) {
    final dot = path.lastIndexOf('.');
    return dot > path.lastIndexOf('/') ? path.substring(dot) : '.jpg';
  }
}
