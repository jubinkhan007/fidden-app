import 'package:fidden/features/business_owner/reviews/state/reviews_filter_controller.dart';

import '../data/review_model.dart';

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime _endOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 23, 59, 59);

List<Review> applyReviewFilters({
  required List<Review> reviews,
  required ReviewsFilterController f,
}) {
  Iterable<Review> r = reviews;

  // service filter (by name)
  final svc = f.selectedServiceName.value.trim().toLowerCase();
  if (svc.isNotEmpty) {
    r = r.where((it) => (it.serviceName).toLowerCase() == svc);
  }

  // search
  final q = f.query.value.trim().toLowerCase();
  if (q.isNotEmpty) {
    r = r.where((it) {
      final hay = [
        it.author,
        it.serviceName,
        it.comment,
        it.reply ?? '',
      ].join(' ').toLowerCase();
      return hay.contains(q);
    });
  }

  // rating
  if (f.minRating.value > 0) {
    r = r.where((it) => (it.rating ?? 0) >= f.minRating.value);
  }

  // reply
  if (f.hasReplyOnly.value) {
    r = r.where((it) => (it.reply ?? '').trim().isNotEmpty);
  }

  // date range
  final from = f.dateFrom.value;
  final to = f.dateTo.value;
  if (from != null) r = r.where((it) => !it.date.isBefore(_startOfDay(from)));
  if (to != null) r = r.where((it) => !it.date.isAfter(_endOfDay(to)));

  // sort
  final list = r.toList();
  switch (f.sort.value) {
    case ReviewsSort.newest:
      list.sort((a, b) => b.date.compareTo(a.date));
      break;
    case ReviewsSort.oldest:
      list.sort((a, b) => a.date.compareTo(b.date));
      break;
    case ReviewsSort.highest:
      list.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      break;
    case ReviewsSort.lowest:
      list.sort((a, b) => (a.rating ?? 0).compareTo(b.rating ?? 0));
      break;
  }
  return list;
}
