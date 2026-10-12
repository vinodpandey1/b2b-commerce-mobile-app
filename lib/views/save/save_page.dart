import '../../core/components/shopping_app_bar.dart';
import 'package:flutter/material.dart';

import 'empty_save_page.dart';

class SavePage extends StatelessWidget {
  const SavePage({
    super.key,
    this.isHomePage = false,
  });

  final bool isHomePage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ShoppingAppBar(title: const Text('Saved products')),
        body: const EmptySavePage());
  }
}
