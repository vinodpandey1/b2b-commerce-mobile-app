import '../utils/shop_categories.dart';
import 'package:flutter/material.dart';
import 'package:EazySupplies/core/constants/apiClients.dart';
import 'package:EazySupplies/core/constants/api_config.dart';
import 'package:EazySupplies/core/models/userModel.dart';
import 'package:EazySupplies/core/routes/app_routes.dart';

Future<User> getUser() async {
  try {
    final response = await ApiClient.dio
        .get(ApiConfig.userProfile)
        .timeout(ApiConfig.timeout);
    if (response.statusCode == 200) {
      final Map<String, dynamic> body =
          Map<String, dynamic>.from(response.data);

      final data = body['data'];
      if (data == null) {
        return User.empty();
      }
      final List orders = data['orders'] ?? [];
      data['ordersCount'] = orders.length;
      return User.fromJson(
        Map<String, dynamic>.from(data),
      );
    }
    return User.empty();
  } catch (e, stack) {
    debugPrint('User API error: $e');
    debugPrint(stack.toString());
    return User.empty();
  }
}

Future<List<Product>> getProducts({
  Iterable<int>? ids,
  bool rethrowErrors = false,
}) async {
  try {
    final productIds = ids?.where((id) => id > 0).toSet().toList() ?? [];
    if (ids != null && productIds.isEmpty) return [];
    if (productIds.length > 100) {
      final products = <Product>[];
      for (var offset = 0; offset < productIds.length; offset += 100) {
        products.addAll(await getProducts(
            ids: productIds.skip(offset).take(100),
            rethrowErrors: rethrowErrors));
      }
      return products;
    }
    final response = await ApiClient.dio.get(
      ApiConfig.products,
      queryParameters: {
        'status': 1,
        'paginate': 100,
        if (productIds.isNotEmpty) 'ids': productIds.join(','),
      },
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200 && response.data is Map) {
      final jsonResponse = Map<String, dynamic>.from(response.data);
      final data = jsonResponse['data'] as List<dynamic>? ?? [];

      final bundles = data
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // ✅ STEP 3: Save API data locally
      //    await LocalStorageService.saveBundles(bundles);

      debugPrint('Loaded bundles from API');
      return bundles;
    } else {
      return [];
    }
  } catch (e) {
    debugPrint('API error: $e');
    if (rethrowErrors) rethrow;
    return [];
  }
}

Future<List<Category>> getCategories() async {
  // 1️⃣ Load local first
  try {
    final response = await ApiClient.dio
        .get(ApiConfig.categories)
        .timeout(ApiConfig.timeout);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = response.data;
      final List<dynamic> data = jsonResponse['data'];
      final categories = data.map((e) => Category.fromJson(e)).toList();

      // 3️⃣ Save locally
      //await LocalStorageService.saveCategories(categories);

      return shopCategories(categories);
    }
  } catch (e) {
    debugPrint('Category API error: $e');
  }

  return [];
}

Future<List<TagModel>> getProductListBasedOnTags() async {
  try {
    final response = await ApiClient.dio
        .get(ApiConfig.tagTogetProduct)
        .timeout(ApiConfig.timeout);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          response.data as Map<String, dynamic>;

      final List<dynamic> data = jsonResponse['data'];

      final List<TagModel> tags =
          data.map((e) => TagModel.fromJson(e)).toList();

      // Save locally (optional)
      // await LocalStorageService.saveTags(tags);

      return tags;
    }
  } catch (e) {
    debugPrint('Tag API error: $e');
  }

  return [];
}

Future<List<Brand>> getBrands() async {
  try {
    final response =
        await ApiClient.dio.get(ApiConfig.brands).timeout(ApiConfig.timeout);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = response.data;
      final List<dynamic> data = jsonResponse['data'];
      final brands = data.map((e) => Brand.fromJson(e)).toList();
      return brands;
    }
  } catch (e) {
    debugPrint('Brand API error: $e');
  }
  return [];
}

Future<List<Address>> getAddress() async {
  try {
    final response =
        await ApiClient.dio.get(ApiConfig.address).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          response.data as Map<String, dynamic>;

      final List<dynamic> data = jsonResponse['data'];

      final List<Address> address =
          data.map<Address>((e) => Address.fromJson(e)).toList();

      return address;
    }
  } catch (e) {
    debugPrint('Address API error: $e');
  }

  return <Address>[]; // empty list of Address
}

Future<Object> getOrders() async {
  try {
    final response =
        await ApiClient.dio.get(ApiConfig.order).timeout(ApiConfig.timeout);
    if (response.statusCode == 200) {
      final Map<String, dynamic> body =
          Map<String, dynamic>.from(response.data);
      final data = body['orders'];
      if (data == null) {
        return Order.empty();
      }
      return Order.fromJson(
        Map<String, dynamic>.from(data),
      );
    }
    return Order.empty();
  } catch (e) {
    debugPrint('User API error: $e');
    return Order.empty();
  }
}

Future<void> _logout(BuildContext context) async {
  // Clear all cookies
  await ApiClient.cookieJar.deleteAll();

  // Navigate to login/signup screen and remove all previous routes
  Navigator.pushNamedAndRemoveUntil(
    context,
    AppRoutes.loginOrSignup,
    (route) => false,
  );
}

Future<List<NotificationModel>> getNotifications() async {
  try {
    final response = await ApiClient.dio.get('/notifications');

    final List list = response.data['notifications'];

    return list.map((e) => NotificationModel.fromJson(e)).toList();
  } catch (e) {
    debugPrint('Notification error: $e');
    rethrow;
  }
}

Future<bool> readNotification(int id) async {
  try {
    final response = await ApiClient.dio.put(
      '/notifications',
      queryParameters: {'id': id},
    );

    return response.statusCode == 200;
  } catch (e) {
    debugPrint('Read notification error: $e');
    return false; // ❗ don’t rethrow for UI actions
  }
}

Future<bool> logout() async {
  try {
    final response = await ApiClient.dio.post('/auth/logout');

    return response.statusCode == 200;
  } catch (e) {
    debugPrint('Logout error: $e');
    return false; // safe for UI actions
  }
}

Future<List<Payment>> getPayments() async {
  try {
    final response =
        await ApiClient.dio.get(ApiConfig.payments).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          response.data as Map<String, dynamic>;

      final List<dynamic> data = jsonResponse['data'];

      final List<Payment> payment =
          data.map<Payment>((e) => Payment.fromJson(e)).toList();

      return payment;
    }
  } catch (e) {
    debugPrint('Address API error: $e');
  }

  return <Payment>[]; // empty list of Address
}
