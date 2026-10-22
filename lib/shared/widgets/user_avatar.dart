import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';

/// Circular avatar with a branded gradient, an optional photo and an online
/// presence ring.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.photoBytes,
    this.size = 48,
    this.online = false,
    this.onTap,
  });

  final String name;
  final String? photoUrl;
  final Uint8List? photoBytes;
  final double size;
  final bool online;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.trim().characters.first;
    final showPhoto = photoUrl != null || photoBytes != null;

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: online ? AppColors.success : Colors.white,
          width: 2,
        ),
        boxShadow: online
            ? const [
                BoxShadow(
                  color: Color(0x3343A047),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: ClipOval(child: showPhoto ? _photo(initial) : _initials(initial)),
    );

    if (onTap == null) return avatar;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: avatar,
    );
  }

  Widget _photo(String initial) {
    final bytes = photoBytes;
    final url = photoUrl;
    return switch ((url, bytes)) {
      (final u?, _) when u.isNotEmpty => Image(
        image: u.startsWith('http') || kIsWeb ? NetworkImage(u) : AssetImage(u),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _initials(initial),
      ),
      (_, final b?) => Image.memory(
        b,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _initials(initial),
      ),
      _ => _initials(initial),
    };
  }

  Widget _initials(String initial) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.brandGradient),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
