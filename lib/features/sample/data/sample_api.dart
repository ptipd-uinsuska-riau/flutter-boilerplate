import 'dart:async';

import 'package:suska_starter/features/sample/data/sample_models.dart';

/// API fitur contoh.
///
/// Versi ini menyimpan data DI MEMORI supaya kerangka bisa dijalankan tanpa
/// backend. Datanya data peraga, bukan data nyata.
///
/// Untuk fitur sungguhan, terima `ApiClient` dan bongkar envelope backend:
///
/// ```dart
/// class LeaveApi {
///   LeaveApi(this._client);
///   final ApiClient _client;
///
///   Future<List<LeaveItem>> list() async {
///     final res = await _client.dio.get<Map<String, dynamic>>('/leave');
///     return unwrapEnvelope(
///       res,
///       (data) => (data as List<dynamic>? ?? const [])
///           .whereType<Map<String, dynamic>>()
///           .map(LeaveItem.fromJson)
///           .toList(),
///     );
///   }
/// }
/// ```
class SampleApi {
  SampleApi({
    List<Map<String, dynamic>>? seed,
    this.delay = const Duration(milliseconds: 350),
  }) : _rows = [...seed ?? _demoRows];

  /// Jeda tiruan jaringan (0 di test).
  final Duration delay;

  final List<Map<String, dynamic>> _rows;
  final _changes = StreamController<void>.broadcast();
  var _nextId = 100;

  /// Memancar setiap data berubah. Layar di kerangka tab hidup terus
  /// (IndexedStack) dan TIDAK dibangun ulang saat halaman formulir ditutup,
  /// jadi cubit daftar mendengarkan ini untuk memuat ulang.
  Stream<void> get changes => _changes.stream;

  Future<List<SampleItem>> list() async {
    await Future<void>.delayed(delay);
    return _rows.map(SampleItem.fromJson).toList();
  }

  Future<SampleItem> create(SampleDraft draft) async {
    await Future<void>.delayed(delay);
    final row = {
      ...draft.toJson(),
      'id': _nextId++,
      'status': SampleStatus.pending.name,
    };
    _rows.insert(0, row);
    _changes.add(null);
    return SampleItem.fromJson(row);
  }

  static const _demoRows = <Map<String, dynamic>>[
    {
      'id': 3,
      'title': 'Peminjaman Ruang Rapat',
      'category': 'Sarana',
      'status': 'pending',
      'start_date': '2026-09-02',
      'end_date': '2026-09-02',
      'note': 'Rapat koordinasi unit',
    },
    {
      'id': 2,
      'title': 'Permohonan Akun Email',
      'category': 'Layanan TI',
      'status': 'approved',
      'start_date': '2026-08-20',
      'end_date': '2026-08-21',
      'note': 'Untuk staf baru',
    },
    {
      'id': 1,
      'title': 'Perbaikan Proyektor',
      'category': 'Sarana',
      'status': 'rejected',
      'start_date': '2026-08-11',
      'end_date': '2026-08-12',
      'note': 'Unit sudah diganti',
    },
  ];
}
