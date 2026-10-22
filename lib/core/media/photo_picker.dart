import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:agri_connect/core/media/prepared_photo.dart';

/// Gateway to the device photo library.
///
/// Abstracted so tests (and, later, a web-oriented implementation) can inject
/// their own picker through [photoPickerProvider].
abstract interface class PhotoPicker {
  Future<List<PreparedPhoto>> pickPhotos({int limit = 5});
}

/// Default picker backed by `image_picker`.
class GalleryPhotoPicker implements PhotoPicker {
  GalleryPhotoPicker();

  final ImagePicker _picker = ImagePicker();
  int _counter = 0;

  @override
  Future<List<PreparedPhoto>> pickPhotos({int limit = 5}) async {
    final files = await _picker.pickMultiImage(limit: limit);
    if (files.isEmpty) return const [];

    final photos = <PreparedPhoto>[];
    for (final file in files) {
      photos.add(await _toPrepared(file));
    }
    return photos;
  }

  Future<PreparedPhoto> _toPrepared(XFile file) async {
    Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (_) {
      bytes = Uint8List(0);
    }
    _counter++;
    return PreparedPhoto(
      id: 'photo_${DateTime.now().microsecondsSinceEpoch}_$_counter',
      name: file.name,
      bytes: bytes,
    );
  }
}

final photoPickerProvider = Provider<PhotoPicker>(
  (ref) => GalleryPhotoPicker(),
);
