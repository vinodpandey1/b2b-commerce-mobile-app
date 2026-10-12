import 'package:flutter/material.dart';
import '../../core/constants/apiCall.dart';
import '../../core/constants/cartStorage.dart';
import '../../core/models/userModel.dart';
import '../../core/components/shopping_app_bar.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/product_availability.dart';
import 'components/single_cart_item_tile.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key, this.isHomePage = false});
  final bool isHomePage;
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<String, int> quantities = {};
  Map<int, Product> products = {};
  final Set<String> saving = {};
  bool loading = true, refreshing = false, checking = false;
  String? loadError;
  @override
  void initState() {
    super.initState();
    CartStorage.quantities.addListener(_sync);
    loadCart();
  }

  @override
  void dispose() {
    CartStorage.quantities.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    if (!mounted) return;
    setState(() => quantities = Map.of(CartStorage.quantities.value));
  }

  Future<void> loadCart() async {
    if (refreshing) return;
    setState(() {
      refreshing = true;
      loadError = null;
    });
    try {
      await CartStorage.getCartItems();
      final items = await getProducts(
          ids: quantities.keys.map(int.parse), rethrowErrors: true);
      if (!mounted) return;
      setState(
          () => products = {for (final product in items) product.id: product});
    } catch (_) {
      if (mounted) {
        setState(() => loadError =
            'We could not refresh your cart. Your saved items are safe.');
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
          refreshing = false;
        });
      }
    }
  }

  Future<void> changeQuantity(String id, int qty) async {
    if (saving.contains(id)) return;
    final previous = quantities[id];
    setState(() {
      saving.add(id);
      if (qty == 0) {
        quantities.remove(id);
      } else {
        quantities[id] = qty;
      }
    });
    try {
      // A stale quantity can always be reduced or removed, even if stock fell.
      final limit = products[int.parse(id)] == null
          ? 0
          : purchaseLimit(products[int.parse(id)]!);
      if (qty > (previous ?? 0) && qty > limit) {
        throw StateError('Stock changed');
      }
      await CartStorage.setQuantity(id, qty,
          maxQuantity:
              qty <= (previous ?? 0) ? CartStorage.maxItemQuantity : limit);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (previous != null) quantities[id] = previous;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Quantity could not be saved. Please try again.')));
    } finally {
      if (mounted) setState(() => saving.remove(id));
    }
  }

  bool get hasUnavailable => quantities.entries.any((e) =>
      cartAvailabilityError(products[int.parse(e.key)], e.value) != null);
  double get total => quantities.entries.fold(
      0, (sum, e) => sum + (products[int.parse(e.key)]?.price ?? 0) * e.value);
  Future<void> checkout() async {
    if (checking || saving.isNotEmpty || refreshing) return;
    setState(() => checking = true);
    try {
      await loadCart();
      if (!mounted ||
          loadError != null ||
          hasUnavailable ||
          quantities.isEmpty) {
        return;
      }
      final user = await getUser();
      if (!mounted) return;
      if (user.id == 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Sign in to checkout. Your cart will stay saved.')));
        await Navigator.pushNamed(context, AppRoutes.introLogin);
        return;
      }
      final items = quantities.entries.map((e) {
        final p = products[int.parse(e.key)]!;
        return <String, dynamic>{
          'productId': p.id,
          'quantity': e.value,
          'price': p.price,
          'name': p.name,
          'product': p
        };
      }).toList();
      await Navigator.pushNamed(context, AppRoutes.checkoutPage,
          arguments: items);
      if (mounted) await loadCart();
    } finally {
      if (mounted) setState(() => checking = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: ShoppingAppBar(title: const Text('Your cart'), showCart: false),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : quantities.isEmpty
                ? Center(
                    child: Padding(
                        padding: const EdgeInsets.all(24),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.shopping_bag_outlined,
                              size: 64, color: Color(0xFF168345)),
                          const SizedBox(height: 16),
                          const Text('Your cart is empty',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          const Text(
                              'Find something you need and add it here.'),
                          const SizedBox(height: 20),
                          ElevatedButton(
                              onPressed: () =>
                                  Navigator.pushNamedAndRemoveUntil(context,
                                      AppRoutes.entryPoint, (_) => false),
                              child: const Text('Back to shop'))
                        ])))
                : RefreshIndicator(
                    onRefresh: loadCart,
                    child: ListView(
                        padding: const EdgeInsets.all(16),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          if (refreshing) const LinearProgressIndicator(),
                          if (loadError != null)
                            Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(children: [
                                  Expanded(child: Text(loadError!)),
                                  TextButton(
                                      onPressed: loadCart,
                                      child: const Text('Retry'))
                                ])),
                          Text('${quantities.length} product(s)',
                              style: const TextStyle(color: Color(0xFF66756B))),
                          const SizedBox(height: 12),
                          for (final e in quantities.entries)
                            SingleCartItemTile(
                                key: ValueKey(e.key),
                                productId: e.key,
                                name: products[int.parse(e.key)]?.name ??
                                    'Unavailable product #${e.key}',
                                quantity: e.value,
                                price: products[int.parse(e.key)]?.price ?? 0,
                                imageUrl:
                                    products[int.parse(e.key)]?.productImage ??
                                        '',
                                maximum: products[int.parse(e.key)] == null
                                    ? 0
                                    : purchaseLimit(
                                        products[int.parse(e.key)]!),
                                error: cartAvailabilityError(
                                    products[int.parse(e.key)], e.value),
                                saving: saving.contains(e.key),
                                onQuantityChanged: changeQuantity,
                                onRemove: (id) => changeQuantity(id, 0),
                                onOpen: products[int.parse(e.key)] == null
                                    ? null
                                    : () async {
                                        await Navigator.pushNamed(
                                            context, AppRoutes.productDetails,
                                            arguments: int.parse(e.key));
                                        if (mounted) await loadCart();
                                      }),
                        ])),
        bottomNavigationBar: loading || quantities.isEmpty
            ? null
            : SafeArea(
                child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        border:
                            Border(top: BorderSide(color: Color(0xFFE3EAE5)))),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                const Text('Subtotal',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)),
                                Text('₹${total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700))
                              ]),
                          if (hasUnavailable)
                            const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                    'Update or remove unavailable items to continue.',
                                    style: TextStyle(color: Colors.redAccent))),
                          TextButton.icon(
                              onPressed: () =>
                                  Navigator.pushNamedAndRemoveUntil(context,
                                      AppRoutes.entryPoint, (_) => false),
                              icon: const Icon(Icons.storefront_outlined),
                              label: const Text('Back to shop')),
                          const SizedBox(height: 12),
                          ElevatedButton(
                              onPressed: hasUnavailable ||
                                      checking ||
                                      refreshing ||
                                      saving.isNotEmpty ||
                                      loadError != null
                                  ? null
                                  : checkout,
                              child: Text(checking
                                  ? 'Checking availability…'
                                  : 'Continue to checkout')),
                        ]))),
      );
}
