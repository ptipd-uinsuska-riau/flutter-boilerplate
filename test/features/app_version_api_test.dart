import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:suska_starter/core/api/api_client.dart';
import 'package:suska_starter/features/app_version/data/app_version_api.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _ok(String path, Map<String, dynamic> data) =>
    Response(
      requestOptions: RequestOptions(path: path),
      data: {'status': 1, 'data': data},
    );

void main() {
  group('AppVersionApi memakai path tunggal (baseURL sudah /api/v1)', () {
    late Dio dio;
    late AppVersionApi api;

    setUp(() {
      dio = _MockDio();
      final client = _MockApiClient();
      when(() => client.dio).thenReturn(dio);
      api = AppVersionApi(client);
    });

    test('checkVersion -> GET /app/check-version', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          '/app/check-version',
          queryParameters: {
            'platform': 'android',
            'version': '1.0.0',
            'build': 3,
          },
        ),
      ).thenAnswer(
        (_) async => _ok('/app/check-version', {
          'update_available': true,
          'is_required': false,
          'latest_version': '1.1.0',
        }),
      );

      // `build` (versionCode terpasang)
      // ikut dikirim supaya BE bisa menghitung `is_required` dari
      // `min_build`.
      final res = await api.checkVersion(
        platform: 'android',
        version: '1.0.0',
        build: 3,
      );

      expect(res.updateAvailable, isTrue);
      expect(res.latestVersion, '1.1.0');
    });
  });
}
