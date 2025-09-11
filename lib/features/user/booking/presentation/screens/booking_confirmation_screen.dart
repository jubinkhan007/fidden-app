// lib/features/user/booking/presentation/screens/booking_confirmation_screen.dart
import 'package:fidden/features/user/home/presentation/screen/home_screen.dart';
import 'package:fidden/features/user/nav_bar/presentation/screens/user_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingConfirmationArgs {
  final String serviceName;
  final String
  dateTimeText; // already formatted, e.g. "Saturday, July 22, 2023 • 6:00 PM"
  final String location; // e.g. "Montreal, Canada"
  final String shopName; // e.g. "Serenity Oasis Spa"
  final int bookingId; // e.g. "#FIDDEN-89327"
  final String? successImage; // asset path for the big green tick (optional)

  const BookingConfirmationArgs({
    required this.serviceName,
    required this.dateTimeText,
    required this.location,
    required this.shopName,
    required this.bookingId,
    this.successImage,
  });
}

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key, this.args, this.onBackToHome});

  /// pass data either via constructor…
  final BookingConfirmationArgs? args;

  /// …or via Get.arguments (fallback if args == null)
  BookingConfirmationArgs get _a {
    if (args != null) return args!;
    final Map<String, dynamic> a = Get.arguments ?? {};
    return BookingConfirmationArgs(
      serviceName: a['serviceName'] ?? '',
      dateTimeText: a['dateTimeText'] ?? '',
      location: a['location'] ?? '',
      shopName: a['shopName'] ?? '',
      bookingId: a['bookingId'] ?? '',
      successImage: a['successImage'],
    );
  }

  /// Where the big red button goes. Defaults to pop to root.
  final VoidCallback? onBackToHome;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF9FAFB);
    const titleColor = Color(0xFF111827);
    const bodyColor = Color(0xFF6B7280);
    const crimson = Color(0xFFDC143C);
    const iconTileBg = Color(0xFFF2EFFA); // soft lilac tile bg

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Get.offAll(() => const UserNavBar()),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Big green check image
              Center(
                child: _SuccessImage(
                  asset: _a.successImage ?? 'assets/images/success_check.jpg',
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 24, thickness: 0.6),

              const SizedBox(height: 8),
              Text(
                "You're Booked!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "We've sent you all the details via email & you'll\nalso get a reminder before your appointment.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: bodyColor,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),

              // Info list
              _InfoTile(
                iconBg: iconTileBg,
                iconAsset:
                    'assets/icons/star_bold.png', // TODO: replace with your asset
                title: 'Service Name',
                subtitle: _a.serviceName,
              ),
              const SizedBox(height: 12),
              _InfoTile(
                iconBg: iconTileBg,
                iconAsset: 'assets/icons/calendar_bold.png', // TODO
                title: 'Date & Time',
                subtitle: _a.dateTimeText,
              ),
              const SizedBox(height: 12),
              _InfoTile(
                iconBg: iconTileBg,
                iconAsset: 'assets/icons/pin_bold.png', // TODO
                title: 'Location',
                subtitle: _a.location,
              ),
              const SizedBox(height: 12),
              _InfoTile(
                iconBg: iconTileBg,
                iconAsset: 'assets/icons/shop_bold.png', // TODO
                title: 'Shop Name',
                subtitle: _a.shopName,
              ),
              const SizedBox(height: 12),
              _InfoTile(
                iconBg: iconTileBg,
                iconAsset: 'assets/icons/tag_bold.png', // TODO
                title: 'Booking ID',
                subtitle: _a.bookingId.toString(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed:
                onBackToHome ?? () => Get.offAll(() => const UserNavBar()),
            style: ElevatedButton.styleFrom(
              backgroundColor: crimson,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Back to Home'),
          ),
        ),
      ),
    );
  }
}

class _SuccessImage extends StatelessWidget {
  const _SuccessImage({required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context) {
    // Square image with some breathing room
    return Image.asset(
      asset,
      width: 140,
      height: 140,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.check_circle, size: 120, color: Colors.green),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.iconBg,
    required this.iconAsset,
    required this.title,
    required this.subtitle,
  });

  final Color iconBg;
  final String iconAsset;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF111827);
    const subColor = Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Image.asset(
              iconAsset,
              width: 26,
              height: 26,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.help_outline),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: subColor,
                    fontSize: 14.5,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
