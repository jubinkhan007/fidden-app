import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Social links row widget for shop details
/// Shows brand-specific icons for Instagram, TikTok, YouTube, and Website
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
              icon: FontAwesomeIcons.instagram, // ✅ Actual Instagram icon
              url: instagramUrl!,
              color: const Color(0xFFE4405F), // Instagram brand color
              label: 'Instagram',
            ),
          if (tiktokUrl != null)
            _SocialButton(
              icon: FontAwesomeIcons.tiktok, // ✅ Actual TikTok icon
              url: tiktokUrl!,
              color: Colors.black,
              label: 'TikTok',
            ),
          if (youtubeUrl != null)
            _SocialButton(
              icon: FontAwesomeIcons.youtube, // ✅ Actual YouTube icon
              url: youtubeUrl!,
              color: const Color(0xFFFF0000), // YouTube brand color
              label: 'YouTube',
            ),
          if (websiteUrl != null)
            _SocialButton(
              icon: FontAwesomeIcons.globe, // Website globe icon
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
            child: Center(child: FaIcon(icon, color: color, size: 22)),
          ),
        ),
      ),
    );
  }
}
