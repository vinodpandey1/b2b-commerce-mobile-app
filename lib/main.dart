import 'package:flutter/material.dart';
import 'package:EazySupplies/core/constants/apiClients.dart';
import 'package:EazySupplies/core/constants/api_config.dart';
import 'core/constants/cartStorage.dart';
import 'core/constants/app_session.dart';
import 'core/routes/on_generate_route.dart';
import 'core/themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.init();
  await CartStorage.getCartItems();
  final bool isLoggedIn = await _checkAuth();
  final initialRoute = await AppSession.initialRoute(authenticated: isLoggedIn);

  runApp(
    MyApp(
      initialRoute: initialRoute,
    ),
  );
}

/// 🔐 Cookie-based auth check
Future<bool> _checkAuth() async {
  try {
    final cookies = await ApiClient.cookieJar.loadForRequest(
      Uri.parse(ApiConfig.baseUrl),
    );

    final now = DateTime.now();

    return cookies.any((c) {
      if (c.name != 'authToken') return false;
      if (c.value.isEmpty) return false;

      // Session cookie (no expiry) → valid
      if (c.expires == null) return true;

      // Persistent cookie → check expiry
      return c.expires!.isAfter(now);
    });
  } catch (e) {
    return false;
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({
    super.key,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EazySupplies',
      theme: AppTheme.defaultTheme,
      scrollBehavior: const EazySuppliesScrollBehavior(),
      onGenerateRoute: RouteGenerator.onGenerate,
      initialRoute: initialRoute,
    );
  }
}

class EazySuppliesScrollBehavior extends MaterialScrollBehavior {
  const EazySuppliesScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    final platform = getPlatform(context);
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      );
    }
    return const ClampingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }
}
