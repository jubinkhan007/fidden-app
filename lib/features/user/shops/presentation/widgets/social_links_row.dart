import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Social links row widget for shop details
/// Shows icons for Instagram, TikTok, YouTube, and Website
class SocialLinksRow extends StatelessWidget {
  final String? instagramUrl;
  final String? tiktokUrl;
  final String? youtubeUrl;
  final String? websiteUrl;

  const SocialLinksRow({
    super.key,
    this.instagramUrl,
    this.tiktokUrl,
    this.youtubeUrl,
    this.websiteUrl,
  });

  /// Check if any social links exist
  bool get hasAnyLinks =>
      instagramUrl != null ||
      tiktokUrl != null ||
      youtubeUrl != null ||
      websiteUrl != null;

  @override
  Widget build(BuildContext context) {
    if (!hasAnyLinks) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (instagramUrl != null)
            _SocialButton(
              icon: Icons.camera_alt_rounded,
              url: instagramUrl!,
              color: const Color(0xFFE4405F),
              label: 'Instagram',
            ),
          if (tiktokUrl != null)
            _SocialButton(
              icon: Icons.music_note_rounded,
              url: tiktokUrl!,
              color: Colors.black,
              label: 'TikTok',
            ),
          if (youtubeUrl != null)
            _SocialButton(
              icon: Icons.play_circle_fill_rounded,
              url: youtubeUrl!,
              color: const Color(0xFFFF0000),
              label: 'YouTube',
            ),
          if (websiteUrl != null)
            _SocialButton(
              icon: Icons.language_rounded,
              url: websiteUrl!,
              color: Colors.blue,
              label: 'Website',
            ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String url;
  final Color color;
  final String label;

  const _SocialButton({
    required this.icon,
    required this.url,
    required this.color,
    required this.label,
  });

  Future<void> _launchUrl() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: _launchUrl,
        borderRadius: BorderRadius.circular(12),
        child: Tooltip(
          message: label,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(icon, color: color, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}
