import 'package:EazySupplies/core/components/shopping_app_bar.dart';
import 'dart:async';

import 'package:EazySupplies/core/constants/apiClients.dart';
import 'package:EazySupplies/core/constants/api_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:EazySupplies/core/models/userModel.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/product_tile_square.dart';
import '../../core/constants/constants.dart';
//import '../../core/models/product_model.dart';

class SearchResultPage extends StatefulWidget {
  const SearchResultPage({super.key});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  List<Product> products = [];
  bool isLoading = false;
  int _searchGeneration = 0;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchSearchResults(query);
    });
  }

  Future<void> fetchSearchResults(String query) async {
    final normalizedQuery = query.trim();
    final generation = ++_searchGeneration;

    if (normalizedQuery.isEmpty) {
      if (!mounted) return;
      setState(() {
        products = [];
        isLoading = false;
      });
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await ApiClient.dio.get(
        ApiConfig.products,
        queryParameters: {
          'status': 1,
          'search': normalizedQuery,
          'paginate': 100,
        },
      );

      if (!mounted || generation != _searchGeneration) return;
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
        debugPrint('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted || generation != _searchGeneration) return;
      setState(() => isLoading = false);
      debugPrint('Search error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShoppingAppBar(
        title: const Text('Search Results'),
        leading: const AppBackButton(),
      ),
      body: Column(
        children: [
          /// Search Field
          Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: TextField(
              controller: _controller,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                labelText: 'Search Field',
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(AppDefaults.padding),
                  child: SvgPicture.asset(AppIcons.search),
                ),
                suffixIconConstraints: const BoxConstraints(),
              ),
            ),
          ),

          /// Result Count
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
              child: Text(
                '${products.length} Products Found',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.black),
              ),
            ),
          ),

          /// Results Grid
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? const Center(child: Text('No products found'))
                    : GridView.builder(
                        padding:
                            const EdgeInsets.only(top: AppDefaults.padding),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          mainAxisExtent: 460 *
                              MediaQuery.textScalerOf(context)
                                  .scale(1)
                                  .clamp(1, 2),
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
        ],
      ),
    );
  }
}
