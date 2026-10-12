import 'package:flutter/material.dart';
import '../constants/cartStorage.dart';
import '../models/userModel.dart';
import '../routes/app_routes.dart';
import '../utils/product_availability.dart';
import 'quantity_stepper.dart';

class ProductCartControls extends StatefulWidget {
  const ProductCartControls(
      {super.key, required this.product, this.accentColor});
  final Product product;
  final Color? accentColor;
  @override
  State<ProductCartControls> createState() => _ProductCartControlsState();
}

class _ProductCartControlsState extends State<ProductCartControls> {
  int selected = 1;
  bool saving = false;
  Future<void> _save(int quantity, {bool adding = false}) async {
    if (saving) return;
    setState(() => saving = true);
    try {
      await CartStorage.setQuantity(widget.product.id.toString(), quantity,
          maxQuantity: purchaseLimit(widget.product));
      if (!mounted) return;
      if (adding) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('$quantity item(s) added to cart'),
            action: SnackBarAction(
                label: 'View cart',
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.cartPage))));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Your cart could not be saved. Please try again.')));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<Map<String, int>>(
        valueListenable: CartStorage.quantities,
        builder: (context, items, _) {
          final limit = purchaseLimit(widget.product);
          final cartQty = items[widget.product.id.toString()] ?? 0;
          final qty =
              cartQty > 0 ? cartQty : selected.clamp(1, limit > 0 ? limit : 1);
          if (limit == 0) {
            return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                    widget.product.status ? 'Out of stock' : 'Unavailable',
                    style: const TextStyle(color: Colors.redAccent)));
          }
          return LayoutBuilder(builder: (context, size) {
            final stepper = QuantityStepper(
                value: qty,
                accentColor: widget.accentColor,
                minimum: cartQty > 0 ? 0 : 1,
                maximum: limit,
                enabled: !saving,
                onChanged: (value) {
                  if (cartQty > 0) {
                    _save(value);
                  } else {
                    setState(() => selected = value);
                  }
                });
            final action = SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: saving
                        ? null
                        : cartQty > 0
                            ? () =>
                                Navigator.pushNamed(context, AppRoutes.cartPage)
                            : () => _save(qty, adding: true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: cartQty > 0
                            ? const Color(0xFF183C2B)
                            : widget.accentColor,
                        foregroundColor:
                            cartQty > 0 || widget.accentColor != null
                                ? Colors.white
                                : null,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 12)),
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(saving
                            ? 'Saving…'
                            : cartQty > 0
                                ? 'Added to cart'
                                : 'Add to cart'))));
            if (size.maxWidth >= 300) {
              return Row(children: [
                stepper,
                const SizedBox(width: 16),
                Expanded(child: action)
              ]);
            }
            return Column(
                children: [stepper, const SizedBox(height: 8), action]);
          });
        },
      );
}
