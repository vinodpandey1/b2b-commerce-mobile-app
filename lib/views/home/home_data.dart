import '../../core/utils/shop_categories.dart';
import '../../core/constants/apiClients.dart';
import '../../core/constants/api_config.dart';
import '../../core/models/userModel.dart';

Map<String, dynamic> homeMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : {};
List<dynamic> homeList(dynamic value) => value is List ? value : [];
bool homeEnabled(dynamic value) => value != false && value != 0 && value != '0';

String homeImageUrl(String path) {
  if (path.startsWith('/api/')) {
    return '${Uri.parse(ApiConfig.baseUrl).origin}$path';
  }
  if (path.startsWith('/assets/')) return 'https://eazysupplies.com$path';
  return path;
}

class HomeBanner {
  const HomeBanner(this.image, this.categoryId, this.title, this.asset);
  final String image;
  final int? categoryId;
  final String title;
  final String asset;
  factory HomeBanner.fromJson(Map<String, dynamic> json, int index) {
    final redirect = homeMap(json['redirect_link']);
    final uri = Uri.tryParse(redirect['link']?.toString() ?? '');
    final id = int.tryParse(uri?.queryParameters['category'] ?? '');
    return HomeBanner(
      homeImageUrl(json['image_url']?.toString() ?? ''),
      id,
      uri?.queryParameters['title'] ?? 'Explore our collection',
      index == 0 ? 'hero-crushes.jpeg' : 'hero-sauces.jpg',
    );
  }
}

class HomeData {
  HomeData(
      {required this.content,
      required this.products,
      required this.categories,
      this.hasError = false});
  final Map<String, dynamic> content;
  final List<Product> products;
  final List<Category> categories;
  final bool hasError;
  Map<String, dynamic> get earthling => homeMap(content['earthling_home']);
  Map<String, dynamic> section(String name) => homeMap(earthling[name]);
  List<HomeBanner> get banners {
    final raw = homeMap(content['home_banner']);
    final result = homeList(raw['banners'])
        .where((e) => homeEnabled(homeMap(e)['status']))
        .toList();
    if (raw.containsKey('banners')) {
      return [
        for (var i = 0; i < result.length; i++)
          HomeBanner.fromJson(homeMap(result[i]), i)
      ];
    }
    return const [
      HomeBanner('', 21, 'Crushes and Bar Syrups', 'hero-crushes.jpeg'),
      HomeBanner('', 32, 'Sauces and Ketchups', 'hero-sauces.jpg'),
    ];
  }

  List<Product> get latest {
    final sorted = [...products];
    sorted.sort((a, b) {
      final aDate =
          DateTime.tryParse(a.createdAt)?.millisecondsSinceEpoch ?? a.id;
      final bDate =
          DateTime.tryParse(b.createdAt)?.millisecondsSinceEpoch ?? b.id;
      return bDate.compareTo(aDate);
    });
    return sorted.take(4).toList();
  }

  List<Product> get popular {
    final ids = homeList(section('featured')['product_ids'])
        .map((e) => int.tryParse('$e'))
        .toSet();
    return products
        .where((p) => ids.isEmpty || ids.contains(p.id))
        .take(8)
        .toList();
  }

  static HomeData parse(dynamic template, dynamic products, dynamic categories,
      {bool hasError = false}) {
    final templateMap = homeMap(template);
    final content =
        homeMap(homeMap(homeMap(templateMap['jsonData'])['data'])['content']);
    final unique = <int, Product>{};
    for (final raw in homeList(homeMap(products)['data'])) {
      final product = Product.fromJson(homeMap(raw));
      if (product.status && product.id > 0) unique[product.id] = product;
    }
    return HomeData(
        content: content,
        products: unique.values.toList(),
        categories: shopCategories(homeList(homeMap(categories)['data'])
            .where((e) => homeEnabled(homeMap(e)['status']))
            .map((e) => Category.fromJson(homeMap(e)))
            .toList()),
        hasError: hasError);
  }
}

class HomeRepository {
  Future<HomeData> load() async {
    var failed = false;
    Future<dynamic> get(String url, Map<String, dynamic> query) async {
      try {
        final response = await ApiClient.dio.get(url, queryParameters: query);
        return response.data;
      } catch (_) {
        failed = true;
        return null;
      }
    }

    final results = await Future.wait([
      get('${ApiConfig.baseUrl}/template', {'name': 'home'}),
      get(ApiConfig.products, {'status': 1, 'paginate': 100}),
      get(ApiConfig.categories, {'status': 1}),
    ]);
    return HomeData.parse(results[0], results[1], results[2], hasError: failed);
  }
}
