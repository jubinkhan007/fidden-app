// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../controller/review_controller.dart';
// import '../../reviews/data/review_model.dart';

// class ReviewsScreen extends StatelessWidget {
//   const ReviewsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final c = Get.put(ReviewController());

//     // UI state (client-side) – lives for the screen’s lifetime
//     final query = ''.obs;
//     final minRating = 0.obs; // 0..5
//     final hasReplyOnly = false.obs;
//     final sort = _Sort.newest.obs;
//     final dateFrom = Rxn<DateTime>();
//     final dateTo = Rxn<DateTime>();

//     List<Review> _applyFilters(List<Review> list) {
//       Iterable<Review> r = list;

//       // search
//       final q = query.value.trim().toLowerCase();
//       if (q.isNotEmpty) {
//         r = r.where((it) {
//           final hay = [
//             it.author,
//             it.serviceName,
//             it.comment,
//             it.reply ?? '',
//           ].join(' ').toLowerCase();
//           return hay.contains(q);
//         });
//       }

//       // rating
//       if (minRating.value > 0) {
//         r = r.where((it) => (it.rating ?? 0) >= minRating.value);
//       }

//       // reply
//       if (hasReplyOnly.value) {
//         r = r.where((it) => (it.reply ?? '').trim().isNotEmpty);
//       }

//       // date range
//       if (dateFrom.value != null) {
//         r = r.where((it) => !it.date.isBefore(_atStartOfDay(dateFrom.value!)));
//       }
//       if (dateTo.value != null) {
//         r = r.where((it) => !it.date.isAfter(_atEndOfDay(dateTo.value!)));
//       }

//       // sort
//       final l = r.toList();
//       switch (sort.value) {
//         case _Sort.newest:
//           l.sort((a, b) => b.date.compareTo(a.date));
//           break;
//         case _Sort.oldest:
//           l.sort((a, b) => a.date.compareTo(b.date));
//           break;
//         case _Sort.highest:
//           l.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
//           break;
//         case _Sort.lowest:
//           l.sort((a, b) => (a.rating ?? 0).compareTo(b.rating ?? 0));
//           break;
//       }
//       return l;
//     }

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: AppBar(
//         title: const Text('My Reviews'),
//         centerTitle: true,
//         surfaceTintColor: Colors.transparent,
//         backgroundColor: Colors.white,
//         actions: [
//           IconButton(
//             tooltip: 'Filters',
//             icon: const Icon(Icons.tune),
//             onPressed: () async {
//               await _openFilterSheet(
//                 context: context,
//                 minRating: minRating,
//                 hasReplyOnly: hasReplyOnly,
//                 sort: sort,
//                 dateFrom: dateFrom,
//                 dateTo: dateTo,
//               );
//             },
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (c.isLoading.value) {
//           return const _ReviewsLoading();
//         }
//         if (c.reviews.isEmpty) {
//           return const _EmptyState(
//             title: 'No reviews yet',
//             subtitle: 'You’ll see new reviews from customers here.',
//           );
//         }

//         final filtered = _applyFilters(c.reviews);
//         return RefreshIndicator(
//           onRefresh: () async => c.fetchReviews?.call(), // if implemented
//           child: CustomScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             slivers: [
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//                   child: _SearchBar(
//                     hint: 'Search by name, service, comment…',
//                     onChanged: (t) => query.value = t,
//                     onClear: () => query.value = '',
//                   ),
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: _ChipsBar(
//                   minRating: minRating,
//                   hasReplyOnly: hasReplyOnly,
//                   sort: sort,
//                   onTapFilter: () => _openFilterSheet(
//                     context: context,
//                     minRating: minRating,
//                     hasReplyOnly: hasReplyOnly,
//                     sort: sort,
//                     dateFrom: dateFrom,
//                     dateTo: dateTo,
//                   ),
//                   onClearDates: () {
//                     dateFrom.value = null;
//                     dateTo.value = null;
//                   },
//                   dateFrom: dateFrom,
//                   dateTo: dateTo,
//                 ),
//               ),
//               if (filtered.isEmpty)
//                 const SliverToBoxAdapter(
//                   child: Padding(
//                     padding: EdgeInsets.all(24.0),
//                     child: _EmptyState(
//                       title: 'No results',
//                       subtitle:
//                           'Try adjusting your search or clearing filters.',
//                     ),
//                   ),
//                 )
//               else
//                 SliverList.separated(
//                   itemCount: filtered.length,
//                   separatorBuilder: (_, __) => const SizedBox(height: 12),
//                   itemBuilder: (context, i) => ReviewCard(review: filtered[i]),
//                   // padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//                 ),
//             ],
//           ),
//         );
//       }),
//     );
//   }
// }

// /// ============ UI Bits ============

// class _SearchBar extends StatelessWidget {
//   const _SearchBar({
//     required this.hint,
//     required this.onChanged,
//     required this.onClear,
//   });
//   final String hint;
//   final ValueChanged<String> onChanged;
//   final VoidCallback onClear;

//   @override
//   Widget build(BuildContext context) {
//     final controller = TextEditingController();
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFE2E8F0)),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       child: Row(
//         children: [
//           const Icon(Icons.search, color: Color(0xFF64748B)),
//           const SizedBox(width: 8),
//           Expanded(
//             child: TextField(
//               controller: controller,
//               decoration: InputDecoration(
//                 hintText: hint,
//                 border: InputBorder.none,
//               ),
//               onChanged: onChanged,
//             ),
//           ),
//           IconButton(
//             tooltip: 'Clear',
//             icon: const Icon(Icons.close, size: 18, color: Color(0xFF94A3B8)),
//             onPressed: () {
//               controller.clear();
//               onClear();
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ChipsBar extends StatelessWidget {
//   const _ChipsBar({
//     required this.minRating,
//     required this.hasReplyOnly,
//     required this.sort,
//     required this.onTapFilter,
//     required this.onClearDates,
//     required this.dateFrom,
//     required this.dateTo,
//   });

//   final RxInt minRating;
//   final RxBool hasReplyOnly;
//   final Rx<_Sort> sort;
//   final VoidCallback onTapFilter;
//   final VoidCallback onClearDates;
//   final Rxn<DateTime> dateFrom;
//   final Rxn<DateTime> dateTo;

//   @override
//   Widget build(BuildContext context) {
//     final fmt = DateFormat('MMM d');
//     return Obx(() {
//       return Padding(
//         padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//         child: Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: [
//             _chip(
//               icon: Icons.star_rounded,
//               label: minRating.value == 0
//                   ? 'Any rating'
//                   : '≥ ${minRating.value}.0',
//             ),
//             _chip(
//               icon: hasReplyOnly.value
//                   ? Icons.mark_chat_read
//                   : Icons.mark_chat_unread_outlined,
//               label: hasReplyOnly.value ? 'Has reply' : 'All replies',
//             ),
//             _chip(icon: Icons.sort, label: _sortLabel(sort.value)),
//             // GestureDetector(
//             //   onTap: onTapFilter,
//             //   child: Chip(
//             //     avatar: const Icon(Icons.tune, size: 18),
//             //     label: Text(
//             //       (dateFrom.value == null && dateTo.value == null)
//             //           ? 'More filters'
//             //           : '${dateFrom.value != null ? fmt.format(dateFrom.value!) : 'Any'} – ${dateTo.value != null ? fmt.format(dateTo.value!) : 'Any'}',
//             //     ),
//             //     shape: const StadiumBorder(
//             //       side: BorderSide(color: Color(0xFFE2E8F0)),
//             //     ),
//             //     backgroundColor: Colors.white,
//             //   ),
//             // ),
//             if (dateFrom.value != null || dateTo.value != null)
//               ActionChip(
//                 avatar: const Icon(Icons.clear, size: 18),
//                 label: const Text('Clear dates'),
//                 onPressed: onClearDates,
//               ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _chip({required IconData icon, required String label}) {
//     return Chip(
//       avatar: Icon(icon, size: 18, color: const Color(0xFF334155)),
//       label: Text(label),
//       backgroundColor: Colors.white,
//       shape: const StadiumBorder(side: BorderSide(color: Color(0xFFE2E8F0))),
//     );
//   }
// }

// /// ============ Review Card ============

// class ReviewCard extends StatelessWidget {
//   final Review review;
//   const ReviewCard({super.key, required this.review});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<ReviewController>();
//     final replyController = TextEditingController();

//     Widget _avatar() {
//       final url = review.avatarUrl;
//       if ((url).toString().trim().isEmpty) {
//         // initials fallback
//         return CircleAvatar(
//           backgroundColor: const Color(0xFFE2E8F0),
//           child: Text(
//             (review.author.isNotEmpty ? review.author[0] : '?').toUpperCase(),
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF334155),
//             ),
//           ),
//         );
//       }
//       return CircleAvatar(backgroundImage: NetworkImage(url));
//     }

//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(14),
//         side: const BorderSide(color: Color(0xFFE2E8F0)),
//       ),
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(14.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // header
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _avatar(),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         review.author,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 16,
//                           color: Color(0xFF0F172A),
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         'Service: ${review.serviceName}',
//                         style: const TextStyle(
//                           color: Color(0xFF475569),
//                           fontSize: 12.5,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         DateFormat.yMMMd().format(review.date),
//                         style: const TextStyle(
//                           color: Color(0xFF94A3B8),
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     Text(
//                       (review.rating ?? 0).toStringAsFixed(1),
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w800,
//                         fontSize: 16,
//                         color: Color(0xFF111827),
//                       ),
//                     ),
//                     const SizedBox(width: 4),
//                     const Icon(
//                       Icons.star_rounded,
//                       color: Color(0xFFF59E0B),
//                       size: 18,
//                     ),
//                   ],
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),

//             // comment
//             _ExpandableText(review.comment),

//             const SizedBox(height: 12),

//             // reply (view or add)
//             if ((review.reply ?? '').trim().isNotEmpty)
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF8FAFC),
//                   border: Border.all(color: const Color(0xFFE2E8F0)),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Your reply',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF0F172A),
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       review.reply!,
//                       style: const TextStyle(color: Color(0xFF334155)),
//                     ),
//                   ],
//                 ),
//               )
//             else
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton.icon(
//                   icon: const Icon(Icons.reply_outlined),
//                   label: const Text('Reply'),
//                   onPressed: () {
//                     Get.dialog(
//                       _ReplyDialog(
//                         author: review.author,
//                         controller: replyController,
//                         onSend: () {
//                           if (replyController.text.trim().isEmpty) return;
//                           controller.addReply(
//                             review,
//                             replyController.text.trim(),
//                           );
//                           Get.back();
//                         },
//                       ),
//                       barrierDismissible: true,
//                     );
//                   },
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ReplyDialog extends StatelessWidget {
//   const _ReplyDialog({
//     required this.author,
//     required this.controller,
//     required this.onSend,
//   });

//   final String author;
//   final TextEditingController controller;
//   final VoidCallback onSend;

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       insetPadding: const EdgeInsets.symmetric(horizontal: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Reply to $author',
//               style: const TextStyle(fontWeight: FontWeight.w700),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: controller,
//               maxLines: 4,
//               decoration: const InputDecoration(
//                 hintText: 'Write your reply…',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Get.back(),
//                     child: const Text('Cancel'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: onSend,
//                     icon: const Icon(Icons.send),
//                     label: const Text('Send'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// expandable comment for long text
// class _ExpandableText extends StatefulWidget {
//   const _ExpandableText(this.text);
//   final String text;

//   @override
//   State<_ExpandableText> createState() => _ExpandableTextState();
// }

// class _ExpandableTextState extends State<_ExpandableText> {
//   bool expanded = false;

//   @override
//   Widget build(BuildContext context) {
//     final text = widget.text.trim();
//     final short = text.length <= 180;
//     final display = expanded || short ? text : '${text.substring(0, 180)}…';

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(display, style: const TextStyle(color: Color(0xFF111827))),
//         if (!short)
//           TextButton(
//             onPressed: () => setState(() => expanded = !expanded),
//             child: Text(expanded ? 'Show less' : 'Read more'),
//           ),
//       ],
//     );
//   }
// }

// /// Loading + Empty

// class _ReviewsLoading extends StatelessWidget {
//   const _ReviewsLoading();

//   @override
//   Widget build(BuildContext context) {
//     return ListView.separated(
//       padding: const EdgeInsets.all(16),
//       itemCount: 5,
//       separatorBuilder: (_, __) => const SizedBox(height: 12),
//       itemBuilder: (_, __) => Container(
//         height: 112,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: const Color(0xFFE2E8F0)),
//           borderRadius: BorderRadius.circular(14),
//         ),
//       ),
//     );
//   }
// }

// class _EmptyState extends StatelessWidget {
//   const _EmptyState({required this.title, required this.subtitle});
//   final String title;
//   final String subtitle;

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(
//               Icons.reviews_outlined,
//               size: 44,
//               color: Color(0xFF94A3B8),
//             ),
//             const SizedBox(height: 12),
//             Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
//             const SizedBox(height: 6),
//             Text(
//               subtitle,
//               textAlign: TextAlign.center,
//               style: const TextStyle(color: Color(0xFF64748B)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Bottom sheet filter UI

// Future<void> _openFilterSheet({
//   required BuildContext context,
//   required RxInt minRating,
//   required RxBool hasReplyOnly,
//   required Rx<_Sort> sort,
//   required Rxn<DateTime> dateFrom,
//   required Rxn<DateTime> dateTo,
// }) async {
//   await Get.bottomSheet(
//     SafeArea(
//       child: Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
//         ),
//         padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//         child: Obx(() {
//           return Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 height: 4,
//                 width: 48,
//                 margin: const EdgeInsets.only(bottom: 12),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFE2E8F0),
//                   borderRadius: BorderRadius.circular(999),
//                 ),
//               ),
//               const Text(
//                 'Filters',
//                 style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
//               ),
//               const SizedBox(height: 14),

//               // Rating
//               Row(
//                 children: [
//                   const Text(
//                     'Min rating',
//                     style: TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                   const Spacer(),
//                   DropdownButton<int>(
//                     value: minRating.value,
//                     onChanged: (v) => minRating.value = v ?? 0,
//                     items: [0, 1, 2, 3, 4, 5]
//                         .map(
//                           (e) => DropdownMenuItem(
//                             value: e,
//                             child: Text(e == 0 ? 'Any' : '$e.0+'),
//                           ),
//                         )
//                         .toList(),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 6),

//               // Reply
//               SwitchListTile(
//                 contentPadding: EdgeInsets.zero,
//                 value: hasReplyOnly.value,
//                 onChanged: (v) => hasReplyOnly.value = v,
//                 title: const Text('Has reply only'),
//               ),

//               // Sort
//               Row(
//                 children: [
//                   const Text(
//                     'Sort by',
//                     style: TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                   const Spacer(),
//                   DropdownButton<_Sort>(
//                     value: sort.value,
//                     onChanged: (v) => sort.value = v ?? _Sort.newest,
//                     items: _Sort.values
//                         .map(
//                           (e) => DropdownMenuItem(
//                             value: e,
//                             child: Text(_sortLabel(e)),
//                           ),
//                         )
//                         .toList(),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 6),

//               // Dates
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       icon: const Icon(Icons.calendar_month),
//                       label: Text(
//                         dateFrom.value == null
//                             ? 'From'
//                             : DateFormat.yMMMd().format(dateFrom.value!),
//                       ),
//                       onPressed: () async {
//                         final picked = await showDatePicker(
//                           context: context,
//                           firstDate: DateTime(2018),
//                           lastDate: DateTime.now().add(
//                             const Duration(days: 365),
//                           ),
//                           initialDate: dateFrom.value ?? DateTime.now(),
//                         );
//                         if (picked != null) dateFrom.value = picked;
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       icon: const Icon(Icons.calendar_month),
//                       label: Text(
//                         dateTo.value == null
//                             ? 'To'
//                             : DateFormat.yMMMd().format(dateTo.value!),
//                       ),
//                       onPressed: () async {
//                         final picked = await showDatePicker(
//                           context: context,
//                           firstDate: DateTime(2018),
//                           lastDate: DateTime.now().add(
//                             const Duration(days: 365),
//                           ),
//                           initialDate: dateTo.value ?? DateTime.now(),
//                         );
//                         if (picked != null) dateTo.value = picked;
//                       },
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () {
//                         minRating.value = 0;
//                         hasReplyOnly.value = false;
//                         sort.value = _Sort.newest;
//                         dateFrom.value = null;
//                         dateTo.value = null;
//                         Get.back();
//                       },
//                       child: const Text('Clear'),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () => Get.back(),
//                       child: const Text('Apply'),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           );
//         }),
//       ),
//     ),
//   );
// }

// enum _Sort { newest, oldest, highest, lowest }

// String _sortLabel(_Sort s) {
//   switch (s) {
//     case _Sort.newest:
//       return 'Newest';
//     case _Sort.oldest:
//       return 'Oldest';
//     case _Sort.highest:
//       return 'Highest rating';
//     case _Sort.lowest:
//       return 'Lowest rating';
//   }
// }

// DateTime _atStartOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
// DateTime _atEndOfDay(DateTime d) =>
//     DateTime(d.year, d.month, d.day, 23, 59, 59);
