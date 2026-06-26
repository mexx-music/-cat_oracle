import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

// ── Result type ────────────────────────────────────────────────────────────

class ImagePickResult {
  const ImagePickResult({
    this.path,
    required this.bytes,
    required this.fileName,
    this.sizeBytes,
  });

  final String? path;
  final Uint8List bytes;
  final String fileName;
  final int? sizeBytes;

  /// Stable string for deterministic analysis seeding.
  String get seedString => path ?? fileName;
}

// ── Exceptions ─────────────────────────────────────────────────────────────

/// Thrown when camera capture is not available on the current platform.
///
/// On macOS, `image_picker` requires a registered `CameraDelegate` which is
/// not bundled with the current project. Show an informative UI message
/// instead of a generic error.
class CameraNotAvailableException implements Exception {
  const CameraNotAvailableException(this.reason);
  final String reason;
  @override
  String toString() => 'CameraNotAvailableException: $reason';
}

/// Thrown when the user denied camera permission.
class CameraPermissionDeniedException implements Exception {
  const CameraPermissionDeniedException();
}

// ── Service ────────────────────────────────────────────────────────────────

enum ImagePickSource { camera, gallery }

class ImagePickService {
  const ImagePickService._();

  /// Platforms where showing a camera button makes sense.
  ///
  /// On macOS the button is shown so users know the feature exists; actual
  /// capture falls back gracefully via [CameraNotAvailableException].
  static bool get supportsCamera {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  /// Pick an image.
  ///
  /// Returns `null` when the user cancelled.
  /// Throws [CameraNotAvailableException] when camera capture is not supported.
  /// Throws [CameraPermissionDeniedException] when the user denied access.
  /// Throws on other unexpected errors.
  static Future<ImagePickResult?> pick({
    ImagePickSource source = ImagePickSource.gallery,
  }) async {
    debugPrint('[ImagePickService] pick() source=$source '
        'platform=$defaultTargetPlatform kIsWeb=$kIsWeb');
    if (source == ImagePickSource.camera && supportsCamera) {
      return _pickCamera();
    }
    return _pickFile();
  }

  // ── File picker (gallery / desktop / web) ───────────────────────────────

  static Future<ImagePickResult?> _pickFile() async {
    debugPrint('[ImagePickService] _pickFile() → FilePicker.pickFiles');
    FilePickerResult? result;
    try {
      result = await FilePicker.pickFiles(
        type: FileType.image,
        withData: true,
      );
    } catch (e, st) {
      debugPrint('[ImagePickService] FilePicker.pickFiles threw: $e\n$st');
      rethrow;
    }
    debugPrint('[ImagePickService] FilePicker returned: '
        '${result == null ? "null (cancelled)" : "${result.files.length} file(s)"}');
    if (result == null || result.files.isEmpty) return null;
    final f = result.files.first;
    debugPrint('[ImagePickService] file: name=${f.name} '
        'path=${f.path} size=${f.size} hasBytes=${f.bytes != null}');
    final bytes = f.bytes;
    if (bytes == null) {
      debugPrint('[ImagePickService] bytes null despite withData:true');
      return null;
    }
    return ImagePickResult(
      path: f.path,
      bytes: bytes,
      fileName: f.name,
      sizeBytes: f.size,
    );
  }

  // ── Camera (iOS / Android; graceful fallback on macOS) ──────────────────

  static Future<ImagePickResult?> _pickCamera() async {
    debugPrint('[ImagePickService] _pickCamera() on $defaultTargetPlatform');
    XFile? xf;
    try {
      xf = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
    } on StateError catch (e) {
      // image_picker_macos throws StateError when no CameraDelegate is set.
      // This is expected: native macOS camera capture requires a separate plugin.
      debugPrint('[ImagePickService] StateError (no camera delegate): $e');
      throw const CameraNotAvailableException(
        'macOS camera capture requires a registered CameraDelegate. '
        'No delegate is currently set.',
      );
    } catch (e, st) {
      debugPrint('[ImagePickService] camera error: $e\n$st');
      // Heuristic: permission denied typically surfaces as a PlatformException
      // with code "camera_access_denied" or similar.
      final msg = e.toString().toLowerCase();
      if (msg.contains('denied') ||
          msg.contains('permission') ||
          msg.contains('access')) {
        throw const CameraPermissionDeniedException();
      }
      rethrow;
    }
    if (xf == null) {
      debugPrint('[ImagePickService] camera: user cancelled');
      return null;
    }
    final bytes = await xf.readAsBytes();
    debugPrint('[ImagePickService] camera captured: ${xf.name} '
        '(${bytes.length} bytes)');
    return ImagePickResult(
      path: xf.path,
      bytes: bytes,
      fileName: xf.name,
    );
  }
}
