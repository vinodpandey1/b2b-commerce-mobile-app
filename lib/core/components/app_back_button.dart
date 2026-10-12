import '../constants/app_session.dart';
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});
  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: 'Back',
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () async {
          final navigator = Navigator.of(context);
          if (navigator.canPop()) {
            navigator.maybePop();
          } else {
            await AppSession.startGuestSession();
            if (!context.mounted) return;
            navigator.pushNamedAndRemoveUntil(
                AppRoutes.entryPoint, (_) => false);
          }
        },
      );
}
