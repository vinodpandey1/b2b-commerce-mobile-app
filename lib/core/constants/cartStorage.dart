import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartStorage {
  static const String _cartKey = 'cart_items';
  static const int maxItemQuantity = 100;
  static Future<void> _writes = Future<void>.value();
  static final quantities = ValueNotifier<Map<String, int>>({});

  static int _quantity(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  static List<Map<String, dynamic>> _read(SharedPreferences prefs) {
    final saved = prefs.getString(_cartKey);
    if (saved == null || saved.isEmpty) return [];
    dynamic decoded;
    try {
      decoded = jsonDecode(saved);
    } on FormatException {
      return [];
    }
    if (decoded is! List) return [];
    final items = <String, int>{};
    for (final item in decoded.whereType<Map>()) {
      final id = int.tryParse('${item['id']}')?.toString() ?? '';
      final qty = _quantity(item['itemQty']);
      if ((int.tryParse(id) ?? 0) > 0 && qty > 0) items[id] = qty;
    }
    return [
      for (final entry in items.entries)
        {'id': entry.key, 'itemQty': entry.value}
    ];
  }

  static void _publish(List<Map<String, dynamic>> items) {
    quantities.value = {
      for (final item in items) item['id'] as String: item['itemQty'] as int
    };
  }

  // Serialize complete read/modify/write operations so concurrent taps on
  // different products never overwrite another product's saved cart.
  static Future<void> _mutate(
      void Function(List<Map<String, dynamic>>) change) {
    final operation = _writes.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      final items = _read(prefs);
      change(items);
      if (!await prefs.setString(_cartKey, jsonEncode(items))) {
        throw StateError('Your cart could not be saved. Please try again.');
      }
      _publish(items);
    });
    _writes =
        operation.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return operation;
  }

  static void _validate(String id, int qty, int maximum) {
    if ((int.tryParse(id) ?? 0) < 1) {
      throw ArgumentError('Invalid product reference');
    }
    if (qty < 0 || qty > maximum) {
      throw RangeError('Select a quantity between 0 and $maximum.');
    }
  }

  static Future<void> addToCart(String productId, int qty,
      {int maxQuantity = maxItemQuantity}) {
    final maximum = maxQuantity.clamp(0, maxItemQuantity);
    if (qty <= 0) {
      return Future.error(ArgumentError('Select at least one item'));
    }
    return _mutate((items) {
      final index = items.indexWhere((item) => item['id'] == productId);
      final total = (index < 0 ? 0 : items[index]['itemQty'] as int) + qty;
      _validate(productId, total, maximum);
      if (index < 0) {
        items.add({'id': productId, 'itemQty': total});
      } else {
        items[index]['itemQty'] = total;
      }
    });
  }

  static Future<List<Map<String, dynamic>>> getCartItems() async {
    await _writes;
    final items = _read(await SharedPreferences.getInstance());
    _publish(items);
    return items;
  }

  static Future<void> setQuantity(String productId, int qty,
          {int maxQuantity = maxItemQuantity}) =>
      _mutate((items) {
        _validate(productId, qty, maxQuantity.clamp(0, maxItemQuantity));
        final index = items.indexWhere((item) => item['id'] == productId);
        if (qty == 0) {
          items.removeWhere((item) => item['id'] == productId);
        } else if (index < 0) {
          items.add({'id': productId, 'itemQty': qty});
        } else {
          items[index]['itemQty'] = qty;
        }
      });

  static Future<void> updateCartQty(String id, int qty) => setQuantity(id, qty);
  static Future<void> removeFromCart(String id) => setQuantity(id, 0);
  static Future<bool> isInCart(String id) async => (await getItemQty(id)) > 0;
  static Future<bool> isNotInCart(String id) async => !await isInCart(id);
  static Future<int> getItemQty(String id) async {
    await getCartItems();
    return quantities.value[id] ?? 0;
  }

  static Future<void> increaseQty(String id) => addToCart(id, 1);
  static Future<void> decreaseQty(String id) => _mutate((items) {
        final index = items.indexWhere((item) => item['id'] == id);
        if (index < 0) return;
        final qty = (items[index]['itemQty'] as int) - 1;
        if (qty <= 0) {
          items.removeAt(index);
        } else {
          items[index]['itemQty'] = qty;
        }
      });
  static Future<void> clearCart() => _mutate((items) => items.clear());
}
