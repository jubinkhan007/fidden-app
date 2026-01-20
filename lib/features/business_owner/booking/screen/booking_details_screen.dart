import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fidden/core/utils/time_display_helper.dart';
import 'package:fidden/features/business_owner/home/model/business_owner_booking_model.dart';
import 'package:fidden/features/user/checkout/controller/checkout_controller.dart';
import 'package:fidden/features/business_owner/hairstylist/services/hairstylist_service.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key});

  // ---- helpers --------------------------------------------------------------

  OwnerBookingItem _getBooking() {
    final args = Get.arguments;
    if (args is OwnerBookingItem) return args;
    if (args is Map && args['booking'] is OwnerBookingItem) {
      return args['booking'] as OwnerBookingItem;
    }
    final now = DateTime.now();
    return OwnerBookingItem(
      id: 0,
      user: 0,
      userEmail: '',
      userName: 'Customer',
      profileImage: null,
      shop: 0,
      shopName: '',
      slot: 0,
      slotTime: now,
      slotTimeIso: now.toIso8601String(),
      serviceTitle: '',
      serviceDuration: '',
      status: 'scheduled',
      createdAt: now,
      updatedAt: now,
    );
  }

  // Use centralized time display helper for consistent timezone handling
  String _fmtDate(OwnerBookingItem b) => TimeDisplayHelper.formatDateForPro(
    b.slotTimeIso,
    b.shopTimezone,
    format: 'EEE, MMM d, yyyy',
  );

  String _fmtTime(OwnerBookingItem b) =>
      TimeDisplayHelper.formatTimeForPro(b.slotTimeIso, b.shopTimezone);

  String _fmtMeta(DateTime dt) =>
      TimeDisplayHelper.formatDateTimeForClient(dt.toIso8601String());

  @override
  Widget build(BuildContext context) {
    final b = _getBooking();
    final name = (b.userName?.trim().isNotEmpty == true)
        ? b.userName!.trim()
        : (b.userEmail.isNotEmpty ? b.userEmail : 'Customer');

    final int? durationMins = int.tryParse(b.serviceDuration);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          'Booking Details',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // ── Header: customer & status ──────────────────────────────────────
          SectionCard(
            child: Row(
              children: [
                _Avatar(imageUrl: b.profileImage),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (b.userEmail.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          b.userEmail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          StatusChip(
                            label: (b.status.isEmpty ? 'Scheduled' : b.status),
                            color: b.status.toLowerCase().contains('cancel')
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF10B981),
                          ),
                          const StatusChip(
                            label: 'Paid',
                            color: Color(0xFF3B82F6),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Appointment ────────────────────────────────────────────────────
          SectionCard(
            title: 'Appointment',
            child: Column(
              children: [
                KVRow(
                  icon: Icons.miscellaneous_services_rounded,
                  label: 'Service',
                  value: b.serviceTitle.isEmpty ? '—' : b.serviceTitle,
                ),
                const SizedBox(height: 12),
                KVRow(
                  icon: Icons.store_mall_directory_rounded,
                  label: 'Shop',
                  value: b.shopName.isEmpty ? '—' : b.shopName,
                ),
                const SizedBox(height: 12),
                _DateTimeGrid(date: _fmtDate(b), time: _fmtTime(b)),
                if (durationMins != null) ...[
                  const SizedBox(height: 12),
                  KVRow(
                    icon: Icons.timer_rounded,
                    label: 'Duration',
                    value: '$durationMins min',
                  ),
                ],
                if (b.addOns.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  KVRow(
                    icon: Icons.add_circle_outline_rounded,
                    label: 'Add-ons',
                    value: b.addOns
                        .map((a) => a['title'] ?? a['name'] ?? '')
                        .where((n) => n.toString().isNotEmpty)
                        .join(', '),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Meta ───────────────────────────────────────────────────────────
          SectionCard(
            title: 'Other details',
            child: Column(
              children: [
                KVRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Created',
                  value: _fmtMeta(b.createdAt),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // --- Payment/Deposit Section ---
          if (b.depositStatus != null || b.depositAmount != null) ...[
            const SizedBox(height: 12),
            SectionCard(
              title: 'Payment',
              child: Column(
                children: [
                  if (b.servicePrice != null)
                    KVRow(
                      icon: Icons.attach_money_rounded,
                      label: 'Service',
                      value: '\$${b.servicePrice!.toStringAsFixed(2)}',
                    ),
                  if (b.depositAmount != null) ...[
                    const SizedBox(height: 12),
                    KVRow(
                      icon: Icons.lock_rounded,
                      label: 'Deposit',
                      value: '\$${b.depositAmount!.toStringAsFixed(2)}',
                    ),
                  ],
                  if (b.depositStatus != null) ...[
                    const SizedBox(height: 12),
                    _DepositStatusChip(status: b.depositStatus!),
                  ],
                ],
              ),
            ),
          ],

          // --- Checkout Button (only for held deposits) ---
          if (b.depositStatus?.toLowerCase() == 'held') ...[
            const SizedBox(height: 24),
            _CheckoutButton(bookingId: b.id),
          ],

          // --- Prep Notes Section (hairstylist niche only) ---
          if (b.shopNiche == 'hairstylist') ...[
            const SizedBox(height: 12),
            _PrepNotesSection(bookingId: b.id, initialNotes: b.prepNotes ?? ''),
          ],
        ],
      ),
    );
  }
}

// ────────────────────────── building blocks ────────────────────────────────

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// A robust key–value row with a fixed label column and right-aligned value.
/// Prevents label wrapping and keeps long values readable with ellipsis.
class KVRow extends StatelessWidget {
  const KVRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.labelWidth = 92, // tuned for English; adjust for localization
  });

  final IconData icon;
  final String label;
  final String value;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 10),
        SizedBox(
          width: labelWidth,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

/// Date & Time presented responsively:
/// - side-by-side on wide screens
/// - stacked on narrow screens (< 360 px)
class _DateTimeGrid extends StatelessWidget {
  const _DateTimeGrid({required this.date, required this.time});

  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        KVRow(icon: Icons.calendar_month_rounded, label: 'Date', value: date),
        const SizedBox(height: 12),
        KVRow(icon: Icons.access_time_rounded, label: 'Time', value: time),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final border = Border.all(color: const Color(0xFFE5E7EB));
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
        color: const Color(0xFFF3F4F6),
        image: (imageUrl != null && imageUrl!.trim().isNotEmpty)
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: (imageUrl == null || imageUrl!.trim().isEmpty)
          ? const Icon(Icons.person, color: Color(0xFF9CA3AF))
          : null,
    );
  }
}

/// Deposit status chip with color coding
class _DepositStatusChip extends StatelessWidget {
  const _DepositStatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'held':
        color = const Color(0xFFF59E0B);
        label = 'Deposit Held';
        icon = Icons.schedule_rounded;
        break;
      case 'credited':
        color = const Color(0xFF10B981);
        label = 'Checked Out';
        icon = Icons.check_circle_rounded;
        break;
      case 'forfeited':
        color = const Color(0xFFEF4444);
        label = 'Forfeited';
        icon = Icons.cancel_rounded;
        break;
      default:
        color = const Color(0xFF6B7280);
        label = status;
        icon = Icons.info_rounded;
    }

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        const SizedBox(
          width: 92,
          child: Text(
            'Status',
            maxLines: 1,
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Checkout button for owner to initiate customer checkout
class _CheckoutButton extends StatefulWidget {
  const _CheckoutButton({required this.bookingId});
  final int bookingId;

  @override
  State<_CheckoutButton> createState() => _CheckoutButtonState();
}

class _CheckoutButtonState extends State<_CheckoutButton> {
  bool _isLoading = false;

  Future<void> _initiateCheckout() async {
    setState(() => _isLoading = true);

    final controller = Get.put(CheckoutController());
    final success = await controller.initiateCheckout(widget.bookingId);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        // Optionally: refresh the booking or pop back
        Get.back(result: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _initiateCheckout,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.point_of_sale_rounded),
        label: Text(
          _isLoading ? 'Processing...' : 'Checkout Customer',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

/// Prep Notes section for hairstylist bookings
class _PrepNotesSection extends StatefulWidget {
  const _PrepNotesSection({
    required this.bookingId,
    required this.initialNotes,
  });
  final int bookingId;
  final String initialNotes;

  @override
  State<_PrepNotesSection> createState() => _PrepNotesSectionState();
}

class _PrepNotesSectionState extends State<_PrepNotesSection> {
  late TextEditingController _controller;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNotes);
    _controller.addListener(() {
      final changed = _controller.text != widget.initialNotes;
      if (changed != _hasChanges) {
        setState(() => _hasChanges = changed);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveNotes() async {
    if (!_hasChanges) return;
    setState(() => _isSaving = true);

    try {
      final service = HairstylistService();
      await service.updatePrepNotes(widget.bookingId, _controller.text.trim());
      if (mounted) {
        setState(() => _hasChanges = false);
        Get.snackbar(
          'Saved',
          'Prep notes updated',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save prep notes');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Prep Notes',
      child: Column(
        children: [
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add prep notes for this appointment...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          if (_hasChanges) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveNotes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Notes'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
