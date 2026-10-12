import 'package:flutter/material.dart';
import '../../core/components/shopping_app_bar.dart';
import '../../core/components/product_tile_square.dart';
import '../../core/constants/apiClients.dart';
import '../../core/constants/api_config.dart';
import '../../core/models/userModel.dart';

class CategoryProductPage extends StatefulWidget {
  const CategoryProductPage(
      {super.key, required this.categoryId, required this.categoryName});
  final int categoryId;
  final String categoryName;
  @override
  State<CategoryProductPage> createState() => _CategoryProductPageState();
}

class _CategoryProductPageState extends State<CategoryProductPage> {
  List<Category> categories = [];
  List<Product> products = [];
  late int selectedId;
  late String selectedName;
  bool loading = true;
  bool loadingCategories = true;
  String? error;
  bool categoryError = false;
  int request = 0;

  @override
  void initState() {
    super.initState();
    selectedId = widget.categoryId;
    selectedName = widget.categoryName;
    loadCategories();
    if (selectedId > 0) loadProducts();
  }

  Future<void> loadCategories() async {
    setState(() {
      loadingCategories = true;
      categoryError = false;
    });
    try {
      final response = await ApiClient.dio.get(ApiConfig.categories);
      final data = response.data['data'] as List;
      final available = data
          .whereType<Map>()
          .where((item) =>
              item['status'] == null ||
              item['status'] == true ||
              item['status'] == 1 ||
              item['status'] == '1')
          .map((item) => Category.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      if (!mounted) return;
      setState(() {
        categories = available;
        loadingCategories = false;
      });
      if (selectedId == 0 && categories.isNotEmpty) {
        select(categories.first);
      } else if (selectedId == 0) {
        setState(() => loading = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loadingCategories = false;
        categoryError = true;
        if (selectedId == 0) loading = false;
      });
    }
  }

  void select(Category category) {
    setState(() {
      selectedId = category.id;
      selectedName = category.name;
    });
    loadProducts();
  }

  Future<void> loadProducts() async {
    final current = ++request;
    final categoryId = selectedId;
    setState(() {
      loading = true;
      error = null;
      products = [];
    });
    try {
      final response =
          await ApiClient.dio.get(ApiConfig.products, queryParameters: {
        'status': 1,
        'category_ids': categoryId,
        'paginate': 100,
      });
      final data = (response.data['data'] as List)
          .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      if (!mounted || current != request) return;
      setState(() {
        products = data;
        loading = false;
      });
    } catch (_) {
      if (!mounted || current != request) return;
      setState(() {
        loading = false;
        error = 'Unable to load products';
      });
    }
  }

  Widget sidebar() => SizedBox(
        width: 96,
        child: ColoredBox(
          color: const Color(0xFFEFF9E9),
          child: loadingCategories
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('Categories',
                            style: TextStyle(fontWeight: FontWeight.w700))),
                    if (categoryError)
                      TextButton(
                          onPressed: loadCategories,
                          child: const Text('Retry categories')),
                    for (final category in categories)
                      Semantics(
                          selected: category.id == selectedId,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: category.id == selectedId
                                  ? const Color(0xFF183C2B)
                                  : Colors.transparent,
                              foregroundColor: category.id == selectedId
                                  ? Colors.white
                                  : const Color(0xFF183C2B),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 16),
                              shape: const RoundedRectangleBorder(),
                            ),
                            onPressed: () => select(category),
                            child: Text(category.name,
                                textAlign: TextAlign.center, softWrap: true),
                          )),
                  ],
                ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: ShoppingAppBar(title: Text(selectedName)),
        body: SafeArea(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          sidebar(),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(error!),
                        TextButton(
                            onPressed: loadProducts,
                            child: const Text('Retry')),
                      ]))
                    : products.isEmpty
                        ? const Center(child: Text('No products found'))
                        : LayoutBuilder(
                            builder: (context, constraints) => RefreshIndicator(
                                  onRefresh: loadProducts,
                                  child: GridView.builder(
                                    key: ValueKey(selectedId),
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(12),
                                    itemCount: products.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          constraints.maxWidth >= 800
                                              ? 3
                                              : constraints.maxWidth >= 360
                                                  ? 2
                                                  : 1,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                      mainAxisExtent: 460 *
                                          MediaQuery.textScalerOf(context)
                                              .scale(1)
                                              .clamp(1, 2),
                                    ),
                                    itemBuilder: (_, index) =>
                                        ProductTileSquare(
                                            data: products[index]),
                                  ),
                                )),
          ),
        ])),
      );
}
