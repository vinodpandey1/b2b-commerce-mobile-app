import '../models/userModel.dart';

const webCategoryNames = [
  'Crushes and Bar Syrups',
  'Canned and Bottled Item',
  'Olive Oils',
  'LKK',
  'La Puglia',
  'Breakfast Cereals and Oats',
  'Noodle and Pasta',
  'Peppers and Olives',
  'Food Additives',
  'Karonda and Tooti Frooti',
  'Sauces and Ketchups',
  'Mayonnaise',
  'Herbs and Spices',
  'Namjai',
];

String categoryKey(String value) => value
    .toLowerCase()
    .replaceAll('&', ' and ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

bool isShoppingCategory(Category category) =>
    category.id > 0 &&
    categoryKey(category.name) != 'default' &&
    categoryKey(category.slug) != 'default';

String shopCategoryName(Category category) {
  final key = categoryKey(category.name);
  return webCategoryNames.firstWhere((name) => categoryKey(name) == key,
      orElse: () => category.name.trim());
}

List<Category> shopCategories(Iterable<Category> categories) {
  final unique = <int, Category>{};
  for (final category in categories.where(isShoppingCategory)) {
    unique[category.id] = category;
  }
  int rank(Category category) {
    final index = webCategoryNames.indexOf(shopCategoryName(category));
    return index < 0 ? webCategoryNames.length : index;
  }

  return unique.values.toList()
    ..sort((a, b) {
      final order = rank(a).compareTo(rank(b));
      return order != 0 ? order : a.id.compareTo(b.id);
    });
}
