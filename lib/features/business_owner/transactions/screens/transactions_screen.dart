import 'package:fidden/features/business_owner/transactions/controller/transaction_controller.dart';
import 'package:fidden/features/business_owner/transactions/data/transaction_model.dart';
import 'package:fidden/features/business_owner/transactions/widgets/transaction_card.dart';
import 'package:fidden/features/business_owner/transactions/widgets/transaction_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionController controller = Get.find<TransactionController>();

    // Local UI state
    final RxString statusFilter = 'All'.obs;
    final TextEditingController searchCtrl = TextEditingController();
    final Rx<DateTimeRange?> dateRange = Rx<DateTimeRange?>(null);

    String _formatRange(DateTimeRange r) {
      final f = DateFormat('d MMM');
      return '${f.format(r.start)} – ${f.format(r.end)}';
    }

    bool _inRange(DateTime? dt, DateTimeRange? r) {
      if (dt == null || r == null) return true;
      final d = DateTime(dt.year, dt.month, dt.day);
      final s = DateTime(r.start.year, r.start.month, r.start.day);
      final e = DateTime(r.end.year, r.end.month, r.end.day);
      return (d.isAfter(s) || d.isAtSameMomentAs(s)) &&
             (d.isBefore(e) || d.isAtSameMomentAs(e));
    }

    DateTime? _parseIso(String? iso) {
      if (iso == null || iso.isEmpty) return null;
      try { return DateTime.parse(iso); } catch (_) { return null; }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: true,
      ),
      
      body: Obx(() {
  // local reactive state
  final RxString searchText = (searchCtrl.text).obs; // put this near where you create searchCtrl

DateTime? _toLocalDate(String? iso) {
  if (iso == null || iso.trim().isEmpty) return null;
  try {
    final dt = DateTime.parse(iso).toLocal();
    return DateTime(dt.year, dt.month, dt.day); // strip time
  } catch (_) {
    return null;
  }
}

bool _isWithinRange(DateTime? localDate, DateTimeRange? range) {
  if (range == null) return true;              // no range → allow
  if (localDate == null) return false;         // range set + no date → exclude

  final start = DateTime(range.start.year, range.start.month, range.start.day);
  final end   = DateTime(range.end.year,   range.end.month,   range.end.day);

  final d = localDate;
  final afterOrSameStart = !d.isBefore(start); // d >= start
  final beforeOrSameEnd  = !d.isAfter(end);    // d <= end
  return afterOrSameStart && beforeOrSameEnd;  // inclusive bounds
}

  // helpers (use your latest _toLocalDate/_isWithinRange)
  bool matchesStatus(t) => statusFilter.value == 'All'
      ? true
      : (t.status ?? '').toLowerCase() == statusFilter.value.toLowerCase();

  bool matchesDate(t) =>
      _isWithinRange(_toLocalDate(t.slotTime), dateRange.value);

  bool matchesSearch(t) {
    final q = searchText.value.trim().toLowerCase();
    if (q.isEmpty) return true;
    final hay = [
      t.serviceTitle ?? '',
      (t.userName ?? '').toString(),
      (t.userEmail ?? '').toString(),
      t.shopName ?? '',
    ].join(' ').toLowerCase();
    return hay.contains(q);
  }

  // Map API -> UI labels
String uiStatus(Transaction t) {
  final s = (t.status ?? '').toLowerCase();
  final tt = (t.transactionType ?? '').toLowerCase();

  if (tt == 'refund') return 'refunded';
  if (s == 'cancelled') return 'cancelled';
  if (s == 'succeeded' || s == 'completed') return 'completed';
  return ''; // unknown/other
}

// Use created_at (ISO) for date filtering
DateTime? txnLocalDate(Transaction t) {
  final iso = t.createdAt;
  if (iso == null || iso.isEmpty) return null;
  try {
    final dt = DateTime.parse(iso).toLocal();
    return DateTime(dt.year, dt.month, dt.day); // strip time
  } catch (_) {
    return null;
  }
}

bool isWithin(DateTime? d, DateTimeRange? r) {
  if (r == null) return true;     // no range -> allow all
  if (d == null) return false;    // have range + no date -> exclude
  final s = DateTime(r.start.year, r.start.month, r.start.day);
  final e = DateTime(r.end.year, r.end.month, r.end.day);
  return !d.isBefore(s) && !d.isAfter(e); // inclusive
}

  final filtered = controller.transactions.where((t) {
  // status
  final okStatus = statusFilter.value == 'All'
      ? true
      : uiStatus(t) == statusFilter.value.toLowerCase();

  if (!okStatus) return false;

  // date (created_at)
  if (!isWithin(txnLocalDate(t), dateRange.value)) return false;

  // search
  final q = searchText.value.trim().toLowerCase(); // RxString you keep for search
  if (q.isEmpty) return true;
  final hay = [
    t.serviceTitle ?? '',
    t.userName ?? '',
    t.userEmail ?? '',
    t.shopName ?? '',
  ].join(' ').toLowerCase();
  return hay.contains(q);
}).toList();
  final cs = Theme.of(context).colorScheme;

  return Column(
    children: [
      // Search (updates searchText to trigger Obx)
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: _SearchBar(
          controller: searchCtrl,
          onChanged: (v) => searchText.value = v,
          onClear: () { searchCtrl.clear(); searchText.value = ''; },
        ),
      ),

      // Status chips
      _StatusFilters(
        current: statusFilter,
        onChanged: (v) => statusFilter.value = v,
      ),

      // Date range row (unchanged)
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(now.year - 1),
                    lastDate: DateTime(now.year + 1),
                    initialDateRange: dateRange.value ??
                        DateTimeRange(
                          start: DateTime(now.year, now.month, now.day)
                              .subtract(const Duration(days: 6)),
                          end: DateTime(now.year, now.month, now.day),
                        ),
                  );
                  if (picked != null) dateRange.value = picked;
                },
                icon: const Icon(Icons.date_range),
                label: Text(
                  dateRange.value == null
                      ? 'Date range'
                      : _formatRange(dateRange.value!),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Visibility(
              visible: dateRange.value != null,
              child: IconButton(
                tooltip: 'Clear',
                onPressed: () => dateRange.value = null,
                icon: const Icon(Icons.close),
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 4),

      // LIST AREA ONLY swaps between list/empty/skeleton
      Expanded(
        child: controller.isLoading.value && controller.transactions.isEmpty
            ? const TransactionShimmer()
            : RefreshIndicator(
                onRefresh: () async => controller.fetchTransactions(),
                child: filtered.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 24),
                        children: const [
                          SizedBox(height: 100),
                          _EmptyState(),
                        ],
                      )
                    : ListView.separated(
                        controller: controller.scrollController,
                        padding: const EdgeInsets.only(
                            left: 0, right: 0, bottom: 0, top: 0),
                        itemCount: filtered.length +
                            (controller.isLoadingMore.value ? 1 : 0),
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == filtered.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return TransactionCard(transaction: filtered[index]);
                        },
                      ),
              ),
      ),
    ],
  );
}),

    );
  }
}

/// ---------- Small UI helpers ----------

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final VoidCallback onClear;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search by service, customer or email…',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(icon: const Icon(Icons.close), onPressed: onClear),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  const _StatusFilters({required this.current, required this.onChanged});

  final RxString current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = const ['All', 'completed', 'cancelled', 'refunded'];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final label = labels[i];
          return Obx(() {
            final selected = current.value == label;
            return ChoiceChip(
              label: Text(label[0].toUpperCase() + label.substring(1)),
              selected: selected,
              onSelected: (_) => onChanged(label),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          });
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.receipt_long, size: 56, color: cs.onSurfaceVariant),
        const SizedBox(height: 12),
        const Text(
          'No transactions found',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Pull down to refresh or adjust filters.',
          style: TextStyle(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// 