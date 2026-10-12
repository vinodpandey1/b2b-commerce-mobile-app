import 'product_price.dart';
import 'package:flutter/material.dart';
import '../models/userModel.dart';
import '../routes/app_routes.dart';
import '../utils/product_image_url.dart';
import 'network_image.dart';
import 'product_cart_controls.dart';

class ProductTileSquare extends StatelessWidget {
  const ProductTileSquare({super.key, required this.data});
  final Product data;
  @override
  Widget build(BuildContext context) {
    final urls =
        buildProductImageUrls(data.productImage, version: data.updatedAt);
    return LayoutBuilder(
        builder: (context, constraints) => SizedBox(
              width: constraints.hasBoundedWidth ? null : 190,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE3EAE5))),
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.productDetails,
                                  arguments: data.id),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height: 96,
                                        width: double.infinity,
                                        child: urls.isEmpty
                                            ? const Icon(
                                                Icons.inventory_2_outlined,
                                                color: Colors.grey,
                                                size: 40)
                                            : NetworkImageWithLoader(urls.first,
                                                fit: BoxFit.contain)),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                        height: MediaQuery.textScalerOf(context)
                                                .scale(14) *
                                            2 *
                                            1.3,
                                        child: Text(data.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                height: 1.3))),
                                    const SizedBox(height: 4),
                                    Text(
                                        data.pkgGwt ??
                                            data.dimension ??
                                            'View product details',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF66756B))),
                                    const SizedBox(height: 8),
                                    ProductPrice(product: data, fontSize: 16),
                                    const SizedBox(height: 6),
                                    Text(
                                        !data.status
                                            ? 'Unavailable'
                                            : data.stock <= 0
                                                ? 'Out of stock'
                                                : 'In stock',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: data.status && data.stock > 0
                                                ? const Color(0xFF168345)
                                                : Colors.redAccent)),
                                  ])),
                          const SizedBox(height: 10),
                          if (data.status && data.stock > 0)
                            ProductCartControls(
                                key: ValueKey(data.id), product: data)
                          else
                            SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                    onPressed: null,
                                    child: const Text('Add to cart'))),
                        ])),
              ),
            ));
  }
}
