import '../../core/constants/apiCall.dart';
import '../../core/utils/product_availability.dart';
import 'components/single_cart_item_tile.dart';
import 'package:EazySupplies/core/components/shopping_app_bar.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:EazySupplies/core/constants/apiClients.dart';
import 'package:EazySupplies/core/constants/api_config.dart';
import 'package:EazySupplies/core/constants/cartStorage.dart';
import 'package:EazySupplies/core/models/userModel.dart';
import 'package:EazySupplies/views/cart/components/checkout_address_selector.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/routes/app_routes.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> checkOutList;

  const CheckoutPage({
    super.key,
    required this.checkOutList,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late final List<Map<String, dynamic>> items;
  @override
  void initState() {
    super.initState();
    items = widget.checkOutList.map((e) => Map<String, dynamic>.of(e)).toList();
  }

  Address? selectedAddress;
  bool isLoading = false;
  String? _idempotencyKey;

  double get orderAmount => items.fold<double>(0, (sum, item) {
        final price = (item['price'] as num?)?.toDouble() ?? 0;
        final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
        return sum + (price * quantity);
      });

  String _newIdempotencyKey() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final random = Random.secure().nextInt(1 << 32);
    return 'mobile-$timestamp-$random';
  }

  void onAddressSelected(Address address) {
    setState(() {
      if (selectedAddress?.id != address.id) _idempotencyKey = null;
      selectedAddress = address;
    });
  }

  Future<void> placeOrder() async {
    if (isLoading) return;

    final address = selectedAddress;
    final hasCompleteAddress = address != null &&
        address.address.trim().isNotEmpty &&
        address.city.trim().isNotEmpty &&
        address.zipcode.trim().isNotEmpty;
    if (!hasCompleteAddress) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add and select a complete delivery address.'),
        ),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      if (items.isEmpty) throw StateError('Your cart is empty.');
      if (_idempotencyKey == null) {
        final saved = await CartStorage.getCartItems();
        final savedQuantities = {
          for (final item in saved) item['id']: item['itemQty']
        };
        if (saved.length != items.length ||
            items.any((item) =>
                savedQuantities['${item['productId']}'] != item['quantity'])) {
          throw StateError(
              'Your cart has changed. Please return to the cart and review it before ordering.');
        }
        final freshProducts = await getProducts(
            ids: items.map((e) => e['productId'] as int), rethrowErrors: true);
        final byId = {for (final p in freshProducts) p.id: p};
        bool priceChanged = false;
        for (final item in items) {
          final p = byId[item['productId']];
          final error = cartAvailabilityError(p, item['quantity'] as int);
          if (error != null) {
            throw StateError(
                '${item['name']}: $error. Please update your cart.');
          }
          if (item['price'] != p!.price) {
            item['price'] = p.price;
            priceChanged = true;
          }
          item['product'] = p;
        }
        if (priceChanged) {
          _idempotencyKey = null;
          throw StateError(
              'Prices have changed. Please review the updated total and place your order again.');
        }
      }
      _idempotencyKey ??= _newIdempotencyKey();
      final payload = {
        "status": "PENDING",
        "items": items
            .map((item) => {
                  'productId': item['productId'],
                  'quantity': item['quantity'],
                  'price': item['price'],
                  'name': item['name']
                })
            .toList(),
        "shipping": {
          "address": address.address.trim(),
          "city": address.city.trim(),
          "state": "NA",
          "postalCode": address.zipcode.trim(),
          "country": "India"
        },
        "payment": {
          "method": "CREDIT_CARD",
          "status": "PENDING",
          "amount": orderAmount,
        },
        "jsonData": {"source": "mobile"},
      };
      final response = await ApiClient.dio
          .post(
            ApiConfig.orders,
            data: payload,
            options: Options(
              headers: {'Idempotency-Key': _idempotencyKey!},
            ),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await CartStorage.clearCart();
        _idempotencyKey = null;
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        await Future<void>.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.orderSuccessfull);
      }
    } catch (e) {
      debugPrint('Place order error: $e');
      String? apiMessage;
      if (e is DioException && e.response?.data is Map) {
        final responseData = Map<String, dynamic>.from(e.response!.data);
        apiMessage = (responseData['error'] ??
                responseData['message'] ??
                (responseData['details'] is Map
                    ? responseData['details']['message']
                    : null))
            ?.toString();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            apiMessage ??
                (e is StateError ? e.message.toString() : null) ??
                'We could not place the order. Your cart is still saved; please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> updateQuantity(String id, int qty) async {
    if (isLoading) return;
    final index = items.indexWhere((item) => '${item['productId']}' == id);
    if (index < 0) return;
    final item = items[index];
    final previous = Map<String, dynamic>.of(item);
    setState(() {
      isLoading = true;
      _idempotencyKey = null;
      if (qty == 0) {
        items.removeAt(index);
      } else {
        item['quantity'] = qty;
      }
    });
    try {
      await CartStorage.setQuantity(id, qty,
          maxQuantity: item['product'] is Product
              ? purchaseLimit(item['product'] as Product)
              : 100);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (qty == 0) {
          items.insert(index, previous);
        } else {
          items[index] = previous;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Quantity could not be saved. Please try again.')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShoppingAppBar(
        leading: const AppBackButton(),
        title: const Text('Checkout'),
      ),
      bottomNavigationBar: SafeArea(
          child: PayNowButton(
              selectedAddress: items.isEmpty ? null : selectedAddress,
              placeOrder: placeOrder,
              isLoading: isLoading)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            IgnorePointer(
                ignoring: isLoading,
                child: AddressSelector(onAddressSelected: onAddressSelected)),
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Review your order',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      for (final item in items)
                        SingleCartItemTile(
                            productId: '${item['productId']}',
                            name: item['name'] as String,
                            quantity: item['quantity'] as int,
                            price: (item['price'] as num).toDouble(),
                            imageUrl:
                                (item['product'] as Product?)?.productImage ??
                                    '',
                            maximum: item['product'] is Product
                                ? purchaseLimit(item['product'] as Product)
                                : 100,
                            saving: isLoading,
                            onRemove: (id) => updateQuantity(id, 0),
                            onQuantityChanged: updateQuantity),
                    ])),
            BillingSummary(checkOutList: items),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class PayNowButton extends StatelessWidget {
  final Address? selectedAddress;
  final bool isLoading;

  ///final VoidCallback placeOrder;
  final Future<void> Function() placeOrder;
  const PayNowButton(
      {super.key,
      required this.selectedAddress,
      required this.placeOrder,
      required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: ElevatedButton(
          onPressed: selectedAddress == null || isLoading
              ? null
              : () async => await placeOrder(),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Place Order'),
        ),
      ),
    );
  }
}

class BillingSummary extends StatelessWidget {
  final List<Map<String, dynamic>> checkOutList;

  const BillingSummary({
    super.key,
    required this.checkOutList,
  });

  double get subTotal {
    return checkOutList.fold(0.0, (sum, item) {
      final price = (item['price'] as num?)?.toDouble() ?? 0;
      final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
      return sum + (price * quantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double total = subTotal;

    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Billing Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Items
          ...checkOutList.map((item) {
            final price = (item['price'] as num?)?.toDouble() ?? 0;
            final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item['name']}   x  $quantity',
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('₹${(price * quantity).toStringAsFixed(2)}'),
                ],
              ),
            );
          }),

          const Divider(height: 24),

          _priceRow(
            'Total',
            total,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
