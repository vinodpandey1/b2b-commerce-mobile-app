import 'package:EazySupplies/core/components/shopping_app_bar.dart';
import 'package:EazySupplies/core/constants/apiClients.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:EazySupplies/core/constants/api_config.dart';
import 'package:EazySupplies/core/models/userModel.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/product_tile_square.dart';
import '../../core/constants/constants.dart';

class BrandProductPage extends StatefulWidget {
  final int brandId;
  final String brandName;

  const BrandProductPage({
    super.key,
    required this.brandId,
    required this.brandName,
  });

  @override
  State<BrandProductPage> createState() => _CategoryProductPageState();
}

class _CategoryProductPageState extends State<BrandProductPage> {
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategoryProducts();
  }

  Future<void> fetchCategoryProducts() async {
    try {
      final response = await ApiClient.dio.get(
        ApiConfig.products,
        queryParameters: {
          'status': 1,
          'brand_ids': widget.brandId,
          'paginate': 100,
        },
      );

      if (!mounted) return;
      if (response.statusCode == 200 && response.data is Map) {
        final responseData = Map<String, dynamic>.from(response.data);
        final data = responseData['data'] as List<dynamic>? ?? [];

        setState(() {
          products = data
              .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        debugPrint('Failed to load brand products: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      debugPrint('Error fetching brand products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShoppingAppBar(
        title: Text(widget.brandName),
        leading: const AppBackButton(),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('No products found'))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth >= 1200
                        ? 4
                        : constraints.maxWidth >= 800
                            ? 3
                            : 2;
                    return GridView.builder(
                      padding: const EdgeInsets.all(AppDefaults.padding),
                      itemCount: products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        mainAxisExtent: 460 *
                            MediaQuery.textScalerOf(context)
                                .scale(1)
                                .clamp(1, 2),
                      ),
                      scrollCacheExtent: const ScrollCacheExtent.pixels(900),
                      itemBuilder: (context, index) {
                        return ProductTileSquare(data: products[index]);
                      },
                    );
                  },
                ),
    );
  }
}
