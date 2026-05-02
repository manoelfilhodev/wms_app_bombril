import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'core/app_bootstrap.dart';
import 'core/app_theme.dart';
import 'modules/auth/login_page.dart';
import 'modules/dashboard/dashboard_page.dart';
import 'modules/splash/splash_page.dart';
import 'ui/pages/funcionario_offline_page.dart';
import 'ui/widgets/sync_status_banner.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.initialize();

  ApiClient.setUnauthorizedHandler(() {
    appScaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(content: Text('Sessao expirada. Faca login novamente.')),
    );
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      scaffoldMessengerKey: appScaffoldMessengerKey,
      title: 'Systex WMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.systexDarkTheme,
      darkTheme: AppTheme.systexDarkTheme,
      themeMode: ThemeMode.dark,
      home: const SplashPage(),
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const IgnorePointer(child: SyncStatusBanner()),
          ],
        );
      },
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/funcionarios-offline': (context) => const FuncionarioOfflinePage(),
      },
    );
  }
}
