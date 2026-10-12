import '../../core/components/shopping_app_bar.dart';
import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import 'components/intro_page_background_wrapper.dart';
import 'components/intro_page_body_area.dart';

class IntroLoginPage extends StatelessWidget {
  const IntroLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShoppingAppBar(title: const Text('Welcome'), showCart: false),
      body: const Stack(
        children: [
          IntroLoginBackgroundWrapper(imageURL: AppImages.introBackground1),
          IntroPageBodyArea(),
        ],
      ),
    );
  }
}
