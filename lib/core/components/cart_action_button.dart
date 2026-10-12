import 'package:flutter/material.dart';
import '../constants/cartStorage.dart';
import '../routes/app_routes.dart';

class CartActionButton extends StatelessWidget {
  const CartActionButton({super.key});
  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<Map<String, int>>(
        valueListenable: CartStorage.quantities,
        builder: (context, items, _) {
          final count = items.values.fold<int>(0, (total, qty) => total + qty);
          return IconButton(
            tooltip: 'View cart',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.cartPage),
            icon: Badge(
                isLabelVisible: count > 0,
                label: Text(count > 99 ? '99+' : '$count'),
                child: const Icon(Icons.shopping_cart_outlined)),
          );
        },
      );
}
