import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/review_model.dart';

class ReviewsCacheSnapshot {
  final List<Review> list;
  final DateTime ts;
  ReviewsCacheSnapshot({required this.list, required this.ts});
}

class ReviewsRepository {
  // TTL = 10 minutes (tweak if you like)
  static const _ttl = Duration(minutes: 10);

  String _key(String shopId) => 'reviews::$shopId';

  Future<ReviewsCacheSnapshot> readCache(String shopId) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key(shopId));
    if (raw == null || raw.isEmpty) {
      return ReviewsCacheSnapshot(list: const [], ts: DateTime.fromMillisecondsSinceEpoch(0));
    }
    try {
      final obj = jsonDecode(raw);
      final ts = DateTime.tryParse(obj['ts']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final list = (obj['list'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(Review.fromCacheJson)
          .toList();
      return ReviewsCacheSnapshot(list: list, ts: ts);
    } catch (_) {
      return ReviewsCacheSnapshot(list: const [], ts: DateTime.fromMillisecondsSinceEpoch(0));
    }
  }

  Future<void> writeCache(String shopId, List<Review> list) async {
    final sp = await SharedPreferences.getInstance();
    final payload = jsonEncode({
      'ts': DateTime.now().toIso8601String(),
      'list': list.map((e) => e.toCacheJson()).toList(),
    });
    await sp.setString(_key(shopId), payload);
  }

  bool isStale(DateTime ts) => DateTime.now().difference(ts) > _ttl;

  Future<void> clear(String shopId) async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key(shopId));
  }
}
