import 'package:EazySupplies/core/components/shopping_app_bar.dart';
import 'package:EazySupplies/core/constants/apiClients.dart';
import 'package:EazySupplies/core/constants/api_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:EazySupplies/core/models/userModel.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/product_tile_square.dart';
import '../../core/constants/constants.dart';
//import '../../core/models/product_model.dart';

class NewItemsPage extends StatefulWidget {
  const NewItemsPage({super.key, this.title = 'Latest Eats'});
  final String title;

  @override
  State<NewItemsPage> createState() => _NewItemsPageState();
}

class _NewItemsPageState extends State<NewItemsPage> {
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNewItems();
  }

  Future<void> fetchNewItems() async {
    try {
      final response = await ApiClient.dio.get(
        ApiConfig.products,
        queryParameters: const {
          'status': 1,
          'paginate': 100,
          'field': 'createdAt',
          'sort': 'desc',
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
        debugPrint('Failed to load new items: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      debugPrint('Error fetching new items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShoppingAppBar(
        title: Text(widget.title),
        leading: const AppBackButton(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : products.isEmpty
                  ? const Center(child: Text('No new items found'))
                  : GridView.builder(
                      padding: const EdgeInsets.only(top: AppDefaults.padding),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        mainAxisExtent: 460 *
                            MediaQuery.textScalerOf(context)
                                .scale(1)
                                .clamp(1, 2),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      scrollCacheExtent: const ScrollCacheExtent.pixels(900),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return ProductTileSquare(
                          data: products[index],
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
