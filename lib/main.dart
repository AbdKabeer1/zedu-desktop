import 'package:zedu/core/core.dart';
import 'package:zedu/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await loadAppEnv();
  setupLocator();
  await WindowBoundsController(
    window: windowManager,
    storage: locator<SecureStorageService>(),
  ).restore();

  runApp(const ProviderScope(child: App()));
}
