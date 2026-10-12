import 'package:flutter/material.dart';
import 'category_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const CategoryProductPage(categoryId: 0, categoryName: 'Categories');
}
