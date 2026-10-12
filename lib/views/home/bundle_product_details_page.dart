import 'package:flutter/material.dart';
import 'product_details_page.dart';

class BundleProductDetailsPage extends StatelessWidget {
  const BundleProductDetailsPage({super.key, required this.productId});
  final int productId;
  @override
  Widget build(BuildContext context) =>
      ProductDetailsPage(productId: productId);
}
