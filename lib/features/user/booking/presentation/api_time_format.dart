import 'package:intl/intl.dart';

Map<String,int>? _parts(String iso) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})')
      .firstMatch(iso);
  if (m == null) return null;
  return {
    'y': int.parse(m.group(1)!),
    'M': int.parse(m.group(2)!),
    'd': int.parse(m.group(3)!),
    'H': int.parse(m.group(4)!),
    'm': int.parse(m.group(5)!),
  };
}

String formatApiDate(String iso) {
  final p = _parts(iso); if (p == null) return '—';
  final d = DateTime(p['y']!, p['M']!, p['d']!); // naive date, no TZ shift
  return DateFormat('EEE, d MMM yyyy').format(d);
}

String formatApiTime(String iso) {
  final p = _parts(iso); if (p == null) return '—';
  var h = p['H']!, m = p['m']!;
  final ampm = h >= 12 ? 'PM' : 'AM';
  h = h % 12; if (h == 0) h = 12;
  return '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')} $ampm';
}
