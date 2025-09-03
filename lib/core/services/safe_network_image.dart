// safe_network_image.dart
import 'package:fidden/core/utils/constants/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:fidden/core/utils/constants/image_path.dart';

class SafeNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool asCircle;

  const SafeNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.asCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Image.asset(
      IconPath
          .serviceIcon, // <-- replace with a service placeholder if you have one
      width: width,
      height: height,
      fit: fit,
    );

    // Empty / null URL ⇒ show placeholder immediately
    if (url == null || url!.trim().isEmpty) {
      return _wrap(placeholder);
    }

    final net = Image.network(
      url!,
      width: width,
      height: height,
      fit: fit,
      // Show lightweight skeleton while loading
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      // Any error (including 404) ⇒ placeholder
      errorBuilder: (_, __, ___) => placeholder,
    );

    return _wrap(net);
  }

  Widget _wrap(Widget child) {
    if (asCircle) {
      return ClipOval(child: child);
    }
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }
}
