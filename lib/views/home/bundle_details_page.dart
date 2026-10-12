import 'package:EazySupplies/core/components/shopping_app_bar.dart';
import 'package:flutter/material.dart';

import '../../core/components/app_back_button.dart';

class BundleDetailsPage extends StatelessWidget {
  const BundleDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShoppingAppBar(
        leading: const AppBackButton(),
        title: const Text('Bundle Details Page'),
      ),
    );
  }
}
