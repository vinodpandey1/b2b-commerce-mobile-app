import 'package:EazySupplies/core/constants/apiClients.dart';
import 'package:EazySupplies/core/constants/api_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:EazySupplies/core/models/userModel.dart';

import '../../../core/components/product_tile_square.dart';
import '../../../core/constants/constants.dart';
//import '../../../core/models/product_model.dart';

class ProductGridView extends StatefulWidget {
  const ProductGridView({super.key});

  @override
  State<ProductGridView> createState() => _ProductGridViewState();
}

class _ProductGridViewState extends State<ProductGridView> {
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await ApiClient.dio.get(
        ApiConfig.products,
        queryParameters: const {
          'status': 1,
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
        debugPrint('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      debugPrint('Error fetching products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('No products found'))
              : GridView.builder(
                  padding: const EdgeInsets.only(top: AppDefaults.padding),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 460 *
                        MediaQuery.textScalerOf(context).scale(1).clamp(1, 2),
                  ),
                  scrollCacheExtent: const ScrollCacheExtent.pixels(900),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductTileSquare(
                      data: products[index],
                    );
                  },
                ),
    );
  }
}
