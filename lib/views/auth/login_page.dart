import 'package:EazySupplies/core/components/shopping_app_bar.dart';
import 'package:EazySupplies/core/enums/login_type.dart';
import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import 'components/dont_have_account_row.dart';
import 'components/login_header.dart';
import 'components/login_page_form.dart';
import 'components/social_logins.dart';

class LoginPage extends StatelessWidget {
  final LoginType loginType;
  const LoginPage({super.key, required this.loginType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShoppingAppBar(title: const Text('Sign in')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LoginPageHeader(),
                LoginPageForm(loginType: loginType),
                const SizedBox(height: AppDefaults.padding),
                SocialLogins(loginType: loginType),
                const DontHaveAccountRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
