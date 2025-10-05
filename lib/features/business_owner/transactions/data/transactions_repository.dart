// lib/features/business_owner/transactions/data/transactions_repository.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'transaction_model.dart';

class TransactionsRepository {
  static const _kKey = 'transactions_cache_v1';
  static const _kNextKey = 'transactions_next_v1';
  static const _kTsKey = 'transactions_cached_at_v1';

  Future<({List<Transaction> list, String next, DateTime? ts})> readCache() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kKey);
    final next = p.getString(_kNextKey) ?? '';
    final tsStr = p.getString(_kTsKey);
    final ts = tsStr != null ? DateTime.tryParse(tsStr) : null;

    if (raw == null) return (list: <Transaction>[], next: '', ts: ts);
    final decoded = jsonDecode(raw) as List;
    final list = decoded.map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList();
    return (list: list, next: next, ts: ts);
  }

  Future<void> writeCache(List<Transaction> list, String next) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kKey, jsonEncode(list.map((e) => e.toJson()).toList()));
    await p.setString(_kNextKey, next);
    await p.setString(_kTsKey, DateTime.now().toIso8601String());
  }

  bool isStale(DateTime? ts, {Duration maxAge = const Duration(minutes: 3)}) {
    if (ts == null) return true;
    return DateTime.now().difference(ts) > maxAge;
  }
}
