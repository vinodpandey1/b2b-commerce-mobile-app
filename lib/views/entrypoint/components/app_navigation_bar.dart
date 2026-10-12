import 'package:flutter/material.dart';
import '../../../core/constants/cartStorage.dart';
import '../../home/components/home_product_card.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar(
      {super.key, required this.currentIndex, required this.onNavTap});
  final int currentIndex;
  final ValueChanged<int> onNavTap;
  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<Map<String, int>>(
          valueListenable: CartStorage.quantities,
          builder: (context, items, _) {
            final count = items.values.fold<int>(0, (a, b) => a + b);
            return NavigationBarTheme(
                data: NavigationBarThemeData(
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    indicatorColor: homeMint,
                    height: 68,
                    labelTextStyle: WidgetStateProperty.resolveWith((states) =>
                        TextStyle(
                            fontFamily: 'Gilroy',
                            fontSize: 10,
                            fontWeight: states.contains(WidgetState.selected)
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: homeForest)),
                    iconTheme: const WidgetStatePropertyAll(
                        IconThemeData(color: homeForest, size: 23))),
                child: Container(
                    decoration: const BoxDecoration(
                        border:
                            Border(top: BorderSide(color: Color(0xFFDFE9D8)))),
                    child: NavigationBar(
                        selectedIndex: currentIndex,
                        onDestinationSelected: onNavTap,
                        destinations: [
                          const NavigationDestination(
                              icon: Icon(Icons.home_outlined),
                              selectedIcon: Icon(Icons.home_rounded),
                              label: 'Home'),
                          const NavigationDestination(
                              icon: Icon(Icons.grid_view_outlined),
                              selectedIcon: Icon(Icons.grid_view_rounded),
                              label: 'Categories'),
                          NavigationDestination(
                              icon: Badge(
                                  isLabelVisible: count > 0,
                                  label: Text(count > 99 ? '99+' : '$count'),
                                  child:
                                      const Icon(Icons.shopping_bag_outlined)),
                              label: 'Cart'),
                          const NavigationDestination(
                              icon: Icon(Icons.sell_outlined),
                              selectedIcon: Icon(Icons.sell),
                              label: 'Brands'),
                          const NavigationDestination(
                              icon: Icon(Icons.person_outline),
                              selectedIcon: Icon(Icons.person),
                              label: 'Account'),
                        ])));
          });
}
