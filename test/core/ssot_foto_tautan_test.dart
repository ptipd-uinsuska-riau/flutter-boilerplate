import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:suska_starter/core/api/ssot_api.dart';
import 'package:suska_starter/core/storage/token_storage.dart';

class _MockDio extends Mock implements Dio {}

class _MockTokenStorage extends Mock implements TokenStorage {}

const _path = '/internal/v1/self/profil/foto/tautan';

Response<Map<String, dynamic>> _res(Map<String, dynamic> body) => Response(
      requestOptions: RequestOptions(path: _path),
      data: body,
    );

void main() {
  setUpAll(() => registerFallbackValue(Options()));

  late Dio dio;
  late SsotApi api;

  setUp(() {
    dio = _MockDio();
    final tokens = _MockTokenStorage();
    when(() => tokens.accessToken).thenAnswer((_) async => 'jwt-abc');
    api = SsotApi(tokenStorage: tokens, dio: dio);
  });

  void answer(Map<String, dynamic> body) {
    when(
      () => dio.get<Map<String, dynamic>>(
        _path,
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => _res(body));
  }

  group('SsotApi.getMyFotoTautan — tautan foto bertanda tangan', () {
    test('memanggil endpoint self dengan Bearer token', () async {
      answer({
        'status': 1,
        'data': {
          'file_foto': 'id-1',
          'url': 'https://storage.example/f?sig=x',
          'expires_at': '2026-11-17T10:05:00Z',
        },
      });

      final tautan = await api.getMyFotoTautan();

      expect(tautan?.url, 'https://storage.example/f?sig=x');
      expect(tautan?.fileFoto, 'id-1');
      final options = verify(
        () => dio.get<Map<String, dynamic>>(
          _path,
          options: captureAny(named: 'options'),
        ),
      ).captured.single as Options;
      expect(options.headers?['Authorization'], 'Bearer jwt-abc');
    });

    test('respons tanpa envelope tetap terbaca', () async {
      answer({'file_foto': 'id-2', 'url': 'https://storage.example/g'});

      final tautan = await api.getMyFotoTautan();

      expect(tautan?.url, 'https://storage.example/g');
      expect(tautan?.fileFoto, 'id-2');
    });

    test('url kosong / bukan http / tipe salah -> null (tanpa foto)',
        () async {
      for (final data in <Map<String, dynamic>>[
        {'file_foto': null, 'url': null},
        {'file_foto': 'id', 'url': ''},
        {'file_foto': 'id', 'url': 'id-saja-bukan-url'},
        {'file_foto': 'id', 'url': 42},
      ]) {
        answer({'status': 1, 'data': data});
        expect(await api.getMyFotoTautan(), isNull, reason: '$data');
      }
    });

    test('data bukan objek -> null', () async {
      answer({'status': 1, 'data': null});
      expect(await api.getMyFotoTautan(), isNull);
    });
  });
}
