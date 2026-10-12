import '../../../core/components/product_price.dart';
import 'package:flutter/material.dart';
import '../../../core/models/userModel.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/product_image_url.dart';
import '../../../core/components/network_image.dart';
import '../../../core/components/product_cart_controls.dart';

const homeForest = Color(0xFF183C2B);
const homeLeaf = Color(0xFF4F8F12);
const homeCream = Color(0xFFFFFAF0);
const homeMint = Color(0xFFEFF9E9);

class HomeProductCard extends StatelessWidget {
  const HomeProductCard({super.key, required this.product});
  final Product product;
  @override
  Widget build(BuildContext context) {
    final urls =
        buildProductImageUrls(product.productImage, version: product.updatedAt);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDFE9D8))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.productDetails,
                arguments: product.id),
            child: Column(children: [
              Container(
                  height: 128,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [homeMint, homeCream],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight)),
                  child: urls.isEmpty
                      ? const Icon(Icons.inventory_2_outlined, color: homeLeaf)
                      : NetworkImageWithLoader(urls.first,
                          fit: BoxFit.contain)),
              Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            product.brand.name.isEmpty
                                ? 'EARTHLING'
                                : product.brand.name.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10,
                                color: homeLeaf,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8)),
                        const SizedBox(height: 7),
                        SizedBox(
                            height: MediaQuery.textScalerOf(context).scale(13) *
                                2 *
                                1.35,
                            child: Text(product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.35,
                                    color: homeForest,
                                    fontWeight: FontWeight.w700))),
                        const SizedBox(height: 7),
                        ProductPrice(product: product),
                      ])),
            ])),
        const Spacer(),
        Padding(
            padding: const EdgeInsets.all(10),
            child: ProductCartControls(
                key: ValueKey(product.id),
                product: product,
                accentColor: homeLeaf)),
      ]),
    );
  }
}
