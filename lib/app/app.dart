import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: kIsWeb ? 'Zedu | Team Messaging & Collaboration' : 'Zedu',
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
<<<<<<< HEAD
      builder: (context, child) => DesktopWindowTitleListener(
        child: CreditsPaymentDeepLinkListener(
          child: AuthDeepLinkListener(child: child ?? const SizedBox.shrink()),
=======
      builder: (context, child) => CreditsPaymentDeepLinkListener(
        child: AuthDeepLinkListener(
          child: QuickSwitcherShortcut(child: child ?? const SizedBox.shrink()),
>>>>>>> upstream/staging
        ),
      ),
    );
  }
}
