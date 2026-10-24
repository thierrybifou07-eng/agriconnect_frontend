import 'dart:typed_data';

/// A locally-selected picture attached to a product.
///
/// The raw bytes are kept for local previews and will be uploaded to the
/// backend/Cloudinary once the API is available; until then the picture
/// is flagged as prepared but not yet published.
class PreparedPhoto {
  const PreparedPhoto({required this.id, this.name, this.bytes});

  final String id;

  /// Original file name, kept for the future upload payload.
  final String? name;

  /// Raw image bytes, `null` when the picture only exists remotely.
  final Uint8List? bytes;

  bool get hasPreview => bytes != null;
}
