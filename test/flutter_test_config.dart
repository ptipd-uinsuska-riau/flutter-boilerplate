import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:suska_starter/core/cache/memory_cache.dart';

/// Konfigurasi global test: bersihkan MemoryCache sebelum tiap test agar
/// state dari satu test tak bocor ke test berikutnya (singleton).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUp(MemoryCache.clear);
  await testMain();
}
