import 'package:suska_starter/app/app.dart';
import 'package:suska_starter/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
