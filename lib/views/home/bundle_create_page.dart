import 'package:EazySupplies/core/components/shopping_app_bar.dart';
import 'package:flutter/material.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/constants.dart';
import 'components/bundle_create_bottom_action_bar.dart';
import 'components/bundle_create_food_categories.dart';
import 'components/product_grid_view.dart';

class BundleCreatePage extends StatelessWidget {
  const BundleCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShoppingAppBar(
        leading: const AppBackButton(),
        title: const Text('Add Products'),
      ),
      body: const Column(
        children: [
          // SearchBar(),
          FoodCategories(),
          SizedBox(height: AppDefaults.padding / 2),
          ProductGridView(),
          BottomActionBar(),
        ],
      ),
    );
  }
}
