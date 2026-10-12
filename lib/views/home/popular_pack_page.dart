import 'package:EazySupplies/core/components/shopping_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:EazySupplies/core/models/userModel.dart';
import '../../core/components/bundle_tile_square.dart';
// If needed for Product

class PopularPackPage extends StatelessWidget {
  final TagModel tag;

  const PopularPackPage({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final bundles = tag.product;

    return Scaffold(
      appBar: ShoppingAppBar(title: Text(tag.name)),
      body: bundles.isEmpty
          ? const Center(child: Text('No products available'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisExtent:
                    360 * MediaQuery.textScalerOf(context).scale(1).clamp(1, 2),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: bundles.length,
              itemBuilder: (context, index) {
                return BundleTileSquare(data: bundles[index]);
              },
            ),
    );
  }
}
