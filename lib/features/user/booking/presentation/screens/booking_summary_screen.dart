import 'package:fidden/features/user/booking/controller/booking_summary_controller.dart';
import 'package:fidden/routes/app_routes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer';

// --- FIX: Converted to StatefulWidget for safe argument handling ---
class BookingSummaryScreen extends StatefulWidget {
  const BookingSummaryScreen({super.key});

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  // --- All properties are now state variables ---
  late final String serviceName;
  late final String shopName;
  late final String serviceImg;
  late final String shopAddress;
  late final int serviceDuration;
  late final String selectedSlot;
  late final double servicePrice;
  late final double? discountPrice;
  late final int bookingId; // <-- Will hold the booking ID

  final controller = Get.put(BookingSummaryController());
  late final TapGestureRecognizer _termsTap;

  @override
  void initState() {
    super.initState();
    // --- FIX: Arguments are now safely accessed in initState ---
    final Map<String, dynamic> args = Get.arguments ?? {};

    serviceName = args['serviceName'] ?? '';
    serviceImg = args['service_img'] ?? '';
    shopName = args['shopName'] ?? '';
    shopAddress = args['shopAddress'] ?? '';
    serviceDuration = args['serviceDurationMinutes'] ?? 0;
    selectedSlot = args['selectedSlotLabel'] ?? '';
    servicePrice = (args['price'] is num)
        ? (args['price'] as num).toDouble()
        : double.tryParse('${args['price']}') ?? 0.0;
    discountPrice = (args['discountPrice'] == null)
        ? null
        : double.tryParse('${args['discountPrice']}');

    // Safely get the bookingId
    bookingId = args['bookingId'] as int? ?? 0;

    // Log an error if the bookingId is missing, for easier debugging
    if (bookingId == 0) {
      log('Error: Booking ID is missing on the summary screen.');
    }
    _termsTap = TapGestureRecognizer()..onTap = () {
    Get.toNamed(AppRoute.termsAndCondition); // your GetPage route name
  };
  }

  @override
void dispose() {
  _termsTap.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    const Color primaryTextColor = Color(0xFF111827);
    const Color secondaryTextColor = Color(0xFF6B7280);
    const Color backgroundColor = Color(0xFFF9FAFB);

    // --- FIX: WillPopScope now correctly calls the controller with the bookingId ---
    return WillPopScope(
      onWillPop: () async {
        // This will now correctly call the cancellation API
        await controller.cancelBooking(bookingId);
        return true; // Allow the back navigation to proceed
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text('Booking Summary'),
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Service Details", color: primaryTextColor),
              const SizedBox(height: 12),
              _ServiceDetailsCard(
                serviceName: serviceName,
                shopName: shopName,
                shopAddress: shopAddress,
                duration: serviceDuration,
                serviceImg: serviceImg, // Pass the image URL
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Date & Time", color: primaryTextColor),
              const SizedBox(height: 12),
              _DateTimeCard(selectedSlot: selectedSlot),
              const SizedBox(height: 24),
              _buildSectionTitle("Pricing Details", color: primaryTextColor),
              const SizedBox(height: 12),
              _PricingDetailsCard(
                servicePrice: servicePrice,
                discountPrice: discountPrice,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Pay with", color: primaryTextColor),
              const SizedBox(height: 12),
              const _PaymentMethodCard(),
              const SizedBox(height: 24),
              _buildSectionTitle("Coupon", color: primaryTextColor),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Enter promo code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(
                "Cancellation policy",
                color: primaryTextColor,
              ),
              const SizedBox(height: 8),
              const Text(
                'Appointments can be canceled or rescheduled up to 24 hours in advance with no fee.',
                style: TextStyle(color: secondaryTextColor, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Obx(
                () => Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: controller.isTermsAgreed.value,
                      onChanged: controller.toggleTermsAgreement,
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: secondaryTextColor,
                            fontSize: 14,
                          ),
                          children: [
                            const TextSpan(text: 'I also agree to the '),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: const TextStyle(color: Colors.blue),
                              recognizer: _termsTap,
                            ),
                            const TextSpan(text: ' and '),
                            const TextSpan(
                              text: 'Cancellation Policy.',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(
              () => ElevatedButton(
                onPressed:
                    (controller.isTermsAgreed.value &&
                        !controller.isPaying.value)
                    ? () => controller.payForBooking(
                        bookingId: bookingId,
                        successArgs: {
    'serviceName': serviceName,
    'dateTimeText': selectedSlot, // Use 'dateTimeText' key
    'shopName': shopName,
    'location': shopAddress, // Use 'location' key
    'bookingId': bookingId,
    'service_img': serviceImg,
    'price': servicePrice,
    'discountPrice': discountPrice,
},
                      )
                    : null,

                child: controller.isPaying.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC143C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required Color color}) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
    );
  }
}

// --- WIDGETS ---

class _ServiceDetailsCard extends StatelessWidget {
  final String serviceName;
  final String shopName;
  final String shopAddress;
  final int duration;
  final String serviceImg; // Added serviceImg

  const _ServiceDetailsCard({
    required this.serviceName,
    required this.shopName,
    required this.shopAddress,
    required this.duration,
    required this.serviceImg,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              // --- FIX: Use the actual service image URL ---
              child: Image.network(
                serviceImg.isNotEmpty
                    ? serviceImg
                    : 'https://placehold.co/80x80/cccccc/ffffff?text=Service',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 80),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shopName,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shopAddress,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$duration minutes',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTimeCard extends StatelessWidget {
  final String selectedSlot;
  const _DateTimeCard({required this.selectedSlot});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: const Text('Experience Date & Time'),
        subtitle: Text(selectedSlot),
      ),
    );
  }
}

class _PricingDetailsCard extends StatelessWidget {
  final double servicePrice;
  final double? discountPrice;
  const _PricingDetailsCard({required this.servicePrice, this.discountPrice});

  @override
  Widget build(BuildContext context) {
    final double total = (discountPrice ?? servicePrice);
    final bool hasDiscount =
        discountPrice != null && discountPrice! < servicePrice;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _priceRow('Service Fee', '\$${servicePrice.toStringAsFixed(2)}'),
            if (hasDiscount) ...[
              const SizedBox(height: 8),
              _priceRow(
                'Discount',
                '- \$${(servicePrice - discountPrice!).toStringAsFixed(2)}',
              ),
            ],
            const Divider(height: 24),
            _priceRow(
              'Total Amount',
              '\$${total.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const ListTile(
        leading: Icon(Icons.payment, color: Colors.deepPurple),
        title: Text('Stripe'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
