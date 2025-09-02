import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetThumb extends StatelessWidget {
  const NetThumb({
    super.key,
    required this.url,
    this.w = 56,
    this.h = 56,
    this.borderRadius = 8,
  });

  final String? url;
  final double w, h;
  final double borderRadius;

  // Use any image you like; this matches what you’ve been using elsewhere.
  static const _fallback =
      'https://plus.unsplash.com/premium_photo-1661645788141-8196a45fb483?q=80&w=1170&auto=format&fit=crop';

  @override
  Widget build(BuildContext context) {
    final src = (url != null && url!.trim().isNotEmpty) ? url! : _fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: src,
        width: w,
        height: h,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: const Color(0xFFEFF1F5)),
        errorWidget: (_, __, ___) =>
            Image.network(_fallback, width: w, height: h, fit: BoxFit.cover),
      ),
    );
  }
}
