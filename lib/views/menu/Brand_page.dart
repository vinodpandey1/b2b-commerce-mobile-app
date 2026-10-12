import '../../core/components/shopping_app_bar.dart';
import 'package:EazySupplies/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:EazySupplies/core/constants/apiCall.dart';
import 'package:EazySupplies/core/models/userModel.dart';

import '../../core/constants/constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/brand_image_url.dart';
import 'components/category_tile.dart';

class BrandPage extends StatefulWidget {
  //const BrandPage({super.key});
  const BrandPage({
    super.key,
    this.isHomePage = false,
  });

  final bool isHomePage;

  @override
  State<BrandPage> createState() => _BrandPageState();
}

class _BrandPageState extends State<BrandPage> {
  List<Brand> Brands = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final data = await getBrands(); // fetch from API or local
      if (!mounted) return;
      setState(() {
        Brands = data;
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
        appBar: ShoppingAppBar(title: const Text('Brands')),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: Responsive.hp(context, 32 / 8)),
              Text(
                'Choose a brand',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: Responsive.hp(context, 16 / 8)),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Brands.isEmpty
                        ? const Center(child: Text('No brand found'))
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
                            itemCount: Brands.length,
                            itemBuilder: (context, index) {
                              final brand = Brands[index];
                              return CategoryTile(
                                imageLink: buildBrandImageUrl(brand.image),
                                label: brand.name,
                                backgroundColor: AppColors.primary,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.brandDetails,
                                    arguments: {
                                      'brandId': brand.id,
                                      'brandName': brand.name,
                                    },
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ));
  }
}
