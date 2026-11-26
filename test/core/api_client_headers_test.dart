import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:suska_starter/core/api/api_client.dart';
import 'package:suska_starter/core/api/token_refresher.dart';
import 'package:suska_starter/core/config/app_config.dart';
import 'package:suska_starter/core/storage/token_storage.dart';

class _MockTokenStorage extends Mock implements TokenStorage {}

class _MockRefresher extends Mock implements TokenRefresher {}

/// Backend bisa menolak versi aplikasi lama hanya bila SETIAP request
/// membawa versinya — header dipasang di ApiClient, bukan per panggilan,
/// supaya endpoint baru tak bisa lupa mengirimnya.
void main() {
  test('setiap request membawa header X-App-Version', () {
    final client = ApiClient(
      tokenStorage: _MockTokenStorage(),
      refresher: _MockRefresher(),
    );

    expect(client.dio.options.headers['X-App-Version'], AppConfig.appVersion);
    expect(client.dio.options.headers['X-App-Id'], AppConfig.appId);
  });
}
