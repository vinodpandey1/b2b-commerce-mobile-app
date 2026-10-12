import 'package:EazySupplies/core/components/shopping_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:EazySupplies/core/constants/apiClients.dart';
import 'package:EazySupplies/core/constants/api_config.dart';
import 'package:EazySupplies/core/models/userModel.dart';
import 'package:EazySupplies/core/routes/app_routes.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/constants/app_colors.dart';

class AllOrderPage extends StatefulWidget {
  const AllOrderPage({super.key});

  @override
  State<AllOrderPage> createState() => _AllOrderPageState();
}

class _AllOrderPageState extends State<AllOrderPage> {
  late Future<List<Order>> _ordersFuture;
  late Future<List<Product>> _products;

  @override
  void initState() {
    super.initState();
    _ordersFuture = fetchOrders();
  }

  Future<List<Order>> fetchOrders() async {
    try {
      final response =
          await ApiClient.dio.get(ApiConfig.order).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            Map<String, dynamic>.from(response.data);

        // Extract "data" list
        final List<dynamic> ordersJson = body['data'] ?? [];
        return ordersJson.map((json) {
          try {
            return Order.fromJson(Map<String, dynamic>.from(json));
          } catch (e) {
            rethrow;
          }
        }).toList();
      }

      return [];
    } catch (e) {
      debugPrint('Order API error: $e');

      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: ShoppingAppBar(
          leading: const AppBackButton(),
          title: const Text('My Order'),
        ),
        body: Container(
          color: AppColors.cardColor,
          child: FutureBuilder<List<Order>>(
            future: _ordersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No orders found'),
                );
              }

              final orders = snapshot.data!;
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return OrderCard(order: order);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for Order ID + View Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ID: ${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_red_eye), // View icon
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.orderView,
                        arguments: order);
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Status: ${order.status}'),
            const SizedBox(height: 4),
            Text('Created At: ${order.createdAt.toLocal()}'),
            const SizedBox(height: 8),
            const Text(
              'Items:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                      '${item.productName ?? ''} - Qty: ${item.quantity} - Price: ${item.price}'),
                )),
            if (order.user != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('User: ${order.user!.name}'),
              ),
          ],
        ),
      ),
    );
  }
}
