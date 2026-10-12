import 'package:flutter/material.dart';
import '../../core/components/shopping_app_bar.dart';
import '../../core/components/product_tile_square.dart';
import '../../core/constants/apiClients.dart';
import '../../core/constants/api_config.dart';
import '../../core/models/userModel.dart';
import '../../core/utils/shop_categories.dart';

class CategoryProductPage extends StatefulWidget {
  const CategoryProductPage(
      {super.key, required this.categoryId, required this.categoryName});
  final int categoryId;
  final String categoryName;
  @override
  State<CategoryProductPage> createState() => _CategoryProductPageState();
}

class _CategoryProductPageState extends State<CategoryProductPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
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
  }

  Future<void> loadCategories() async {
    setState(() {
      loadingCategories = true;
      categoryError = false;
    });
    try {
      final response = await ApiClient.dio.get(ApiConfig.categories);
      final data = response.data['data'] as List;
      final available = shopCategories(data
          .whereType<Map>()
          .where((item) =>
              item['status'] == null ||
              item['status'] == true ||
              item['status'] == 1 ||
              item['status'] == '1')
          .map((item) => Category.fromJson(Map<String, dynamic>.from(item)))
          .toList());
      if (!mounted) return;
      setState(() {
        categories = available;
        loadingCategories = false;
      });
      if (categories.isNotEmpty) {
        select(categories.firstWhere((category) => category.id == selectedId,
            orElse: () => categories.first));
      } else {
        setState(() {
          selectedId = 0;
          selectedName = 'Categories';
          loading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loadingCategories = false;
        categoryError = true;
        loading = false;
      });
    }
  }

  void select(Category category) {
    setState(() {
      selectedId = category.id;
      selectedName = shopCategoryName(category);
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

  static const ink = Color(0xFF24251F);
  static const brown = Color(0xFF80502E);
  static const cream = Color(0xFFFFFAF3);

  bool hot(Category category) =>
      shopCategoryName(category) == webCategoryNames.first;

  void showCategories() => scaffoldKey.currentState?.openDrawer();

  Widget categoryDrawer() => Drawer(
        width:
            (MediaQuery.sizeOf(context).width * .88).clamp(260, 360).toDouble(),
        backgroundColor: Colors.white,
        child: SafeArea(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(children: [
                const Expanded(
                    child: Text('All categories',
                        style: TextStyle(
                            color: ink,
                            fontSize: 24,
                            fontWeight: FontWeight.w700))),
                IconButton(
                    tooltip: 'Close categories',
                    onPressed: () => scaffoldKey.currentState?.closeDrawer(),
                    icon: const Icon(Icons.close)),
              ])),
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Choose what you need',
                  style: TextStyle(color: Colors.grey))),
          const SizedBox(height: 16),
          Expanded(
              child: ListView(children: [
            if (loadingCategories)
              const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator())),
            if (categoryError)
              TextButton(
                  onPressed: loadCategories,
                  child: const Text('Retry categories')),
            for (final category in categories)
              Semantics(
                  selected: category.id == selectedId,
                  child: Material(
                      color: category.id == selectedId ? cream : Colors.white,
                      child: InkWell(
                          onTap: () {
                            scaffoldKey.currentState?.closeDrawer();
                            if (category.id != selectedId) select(category);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    left: BorderSide(
                                        color: category.id == selectedId
                                            ? brown
                                            : Colors.transparent,
                                        width: 3))),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 17, vertical: 18),
                            child: Row(children: [
                              Expanded(
                                  child: Text(shopCategoryName(category),
                                      softWrap: true,
                                      style: TextStyle(
                                          fontSize: 16,
                                          height: 1.3,
                                          color: category.id == selectedId
                                              ? brown
                                              : ink,
                                          fontWeight: category.id == selectedId
                                              ? FontWeight.w700
                                              : FontWeight.w500))),
                              if (hot(category))
                                const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Text('Hot',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: brown,
                                            fontWeight: FontWeight.w700))),
                              if (category.id == selectedId)
                                const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(Icons.check_circle,
                                        size: 18, color: brown)),
                            ]),
                          )))),
          ])),
        ])),
      );

  Widget productHeader() => Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        OutlinedButton.icon(
            onPressed: showCategories,
            icon: const Icon(Icons.menu_rounded, size: 20),
            label: const Text('Categories'),
            style: OutlinedButton.styleFrom(
                foregroundColor: brown,
                side: const BorderSide(color: Color(0xFFE1CDBD)))),
        const SizedBox(height: 12),
        Text(selectedName,
            style: const TextStyle(
                color: ink,
                fontSize: 22,
                height: 1.2,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(
            loading
                ? 'Loading products…'
                : '${products.length} ${products.length == 1 ? 'product' : 'products'}',
            style: const TextStyle(color: Color(0xFF6B7067), fontSize: 12)),
      ]));

  Widget productBody() {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(error!),
        TextButton(onPressed: loadProducts, child: const Text('Retry')),
      ]));
    }
    if (products.isEmpty) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.inventory_2_outlined,
                    size: 40, color: Colors.grey),
                const SizedBox(height: 12),
                Text(
                    categoryError
                        ? 'Categories could not be loaded'
                        : categories.isEmpty
                            ? 'No categories available'
                            : 'No products in this category yet',
                    textAlign: TextAlign.center),
                TextButton(
                    onPressed: categoryError || categories.isEmpty
                        ? loadCategories
                        : showCategories,
                    child: Text(categoryError || categories.isEmpty
                        ? 'Retry'
                        : 'Browse categories')),
              ])));
    }
    return LayoutBuilder(
        builder: (context, size) => RefreshIndicator(
              onRefresh: loadProducts,
              child: GridView.builder(
                key: ValueKey(selectedId),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: size.maxWidth >= 1100
                        ? 4
                        : size.maxWidth >= 720
                            ? 3
                            : 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 460 *
                        MediaQuery.textScalerOf(context).scale(1).clamp(1, 2)),
                itemBuilder: (_, index) =>
                    ProductTileSquare(data: products[index]),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: scaffoldKey,
        appBar: ShoppingAppBar(title: const Text('Shop by category')),
        drawer: categoryDrawer(),
        body: SafeArea(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              productHeader(),
              Expanded(child: productBody()),
            ])),
      );
}
