import '../../core/components/product_price.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../core/components/shopping_app_bar.dart';
import '../../core/components/product_cart_controls.dart';
import '../../core/components/product_images_slider.dart';
import '../../core/constants/apiClients.dart';
import '../../core/constants/api_config.dart';
import '../../core/models/userModel.dart';
import '../../core/utils/product_image_url.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key, required this.productId});
  final int productId;
  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  Product? product;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    fetchProduct();
  }

  Future<void> fetchProduct() async {
    if (mounted) setState(() => loading = true);
    try {
      final response = await ApiClient.dio.get(ApiConfig.products,
          queryParameters: {'productId': widget.productId});
      final result =
          Product.fromJson(Map<String, dynamic>.from(response.data['data']));
      if (mounted) setState(() => product = result);
    } catch (_) {
      if (mounted) setState(() => product = null);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = product;
    return Scaffold(
      appBar: ShoppingAppBar(title: const Text('Product details')),
      bottomNavigationBar: item == null
          ? null
          : SafeArea(
              child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      border:
                          Border(top: BorderSide(color: Color(0xFFE3EAE5)))),
                  child: ProductCartControls(product: item))),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : item == null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('We could not load this product.'),
                  TextButton(
                      onPressed: fetchProduct, child: const Text('Try again'))
                ]))
              : ListView(children: [
                  ProductImagesSlider(
                      images: buildProductImageUrls(item.productImage,
                          version: item.updatedAt)),
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Text(item.pkgGwt ?? item.dimension ?? '',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 16),
                            ProductPrice(product: item, fontSize: 26),
                            const SizedBox(height: 10),
                            Text(
                                !item.status
                                    ? 'Unavailable'
                                    : item.stock <= 0
                                        ? 'Out of stock'
                                        : '${item.stock} in stock',
                                style: TextStyle(
                                    color: item.status && item.stock > 0
                                        ? const Color(0xFF168345)
                                        : Colors.redAccent,
                                    fontWeight: FontWeight.w600)),
                            const Divider(height: 32),
                            if (item.brand.name.isNotEmpty)
                              Text('Brand: ${item.brand.name}'),
                            if (item.category.name.isNotEmpty)
                              Text('Category: ${item.category.name}'),
                            const SizedBox(height: 20),
                            const Text('About this product',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700)),
                            Html(
                                data: item.description ??
                                    'No description available.'),
                          ])),
                ]),
    );
  }
}
