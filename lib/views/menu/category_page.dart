import 'package:EazySupplies/core/components/shopping_app_bar.dart';
import 'package:EazySupplies/core/constants/apiClients.dart';
import 'package:flutter/material.dart';
import 'package:EazySupplies/core/constants/api_config.dart';
import 'package:EazySupplies/core/models/userModel.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/product_tile_square.dart';
import '../../core/constants/constants.dart';
import '../../core/routes/app_routes.dart';

class CategoryProductPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryProductPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryProductPage> createState() => _CategoryProductPageState();
}

class _CategoryProductPageState extends State<CategoryProductPage> {
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategoryProducts();
  }

  Future<void> fetchCategoryProducts() async {
    try {
      final response = await ApiClient.dio.get(ApiConfig.products,
          queryParameters: {
            'status': 1,
            'category_ids': widget.categoryId,
            'paginate': 100
          });

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];

        if (!mounted) return;
        setState(() {
          products = data.map((e) => Product.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => isLoading = false);
        debugPrint('Failed to load category products: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      debugPrint('Error fetching category products: $e');
    }
  }

  Widget _breadcrumbLink(String label, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label),
    );
  }

  Widget _buildBreadcrumbs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
      child: Row(
        children: [
          _breadcrumbLink(
            'Home',
            () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.entryPoint,
              (route) => false,
            ),
          ),
          const Icon(Icons.chevron_right, size: 18),
          _breadcrumbLink('Categories', () => Navigator.maybePop(context)),
          const Icon(Icons.chevron_right, size: 18),
          _breadcrumbLink(widget.categoryName, fetchCategoryProducts),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShoppingAppBar(
        title: Text(widget.categoryName),
        leading: const AppBackButton(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBreadcrumbs(),
          Expanded(
            child: isLoading
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
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              mainAxisExtent: 460 *
                                  MediaQuery.textScalerOf(context)
                                      .scale(1)
                                      .clamp(1, 2),
                            ),
                            itemBuilder: (context, index) {
                              return ProductTileSquare(data: products[index]);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
