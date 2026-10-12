import 'package:EazySupplies/core/components/shopping_app_bar.dart';
import 'package:flutter/material.dart';

import '../../core/components/app_back_button.dart';
import 'components/review_lists.dart';
import 'components/review_overview.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShoppingAppBar(
        leading: const AppBackButton(),
        title: const Text('Review'),
      ),
      body: const Column(
        children: [
          ReviewOverview(),
          Divider(thickness: 0.1),
          ReviewLists(),
        ],
      ),
    );
  }
}
