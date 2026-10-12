import '../../core/components/shopping_app_bar.dart';
import 'package:EazySupplies/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:EazySupplies/core/constants/apiCall.dart';
import 'package:EazySupplies/core/models/userModel.dart';

import '../../core/constants/constants.dart';
import '../../core/routes/app_routes.dart';
import 'components/category_tile.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Category> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final data = await getCategories(); // fetch from API or local
      if (!mounted) return;
      setState(() {
        categories = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      debugPrint('Error fetching categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShoppingAppBar(title: const Text('Categories')),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: Responsive.hp(context, 32 / 8)),
            Text(
              'Choose a category',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: Responsive.hp(context, 16 / 8)),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : categories.isEmpty
                      ? const Center(child: Text('No categories found'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(AppDefaults.padding),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio:
                                0.8, // makes tile taller if needed
                          ),
                          scrollCacheExtent:
                              const ScrollCacheExtent.pixels(900),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return CategoryTile(
                              imageLink: "", // add category.image if available
                              label: category.name,
                              backgroundColor: AppColors.primary,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.categoryDetails,
                                  arguments: {
                                    'categoryId': category.id,
                                    'categoryName': category.name,
                                  },
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
