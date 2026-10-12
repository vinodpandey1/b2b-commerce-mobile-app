import 'package:EazySupplies/core/components/shopping_app_bar.dart';
import 'package:EazySupplies/core/constants/apiCall.dart';
import 'package:flutter/material.dart';
import 'package:EazySupplies/core/models/userModel.dart';
import 'package:EazySupplies/core/routes/app_routes.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/constants/app_colors.dart';

class AllPaymentPage extends StatefulWidget {
  const AllPaymentPage({super.key});

  @override
  State<AllPaymentPage> createState() => _AllPaymentPageState();
}

class _AllPaymentPageState extends State<AllPaymentPage> {
  late Future<List<Payment>> _payments;

  @override
  void initState() {
    super.initState();
    _payments = getPayments();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('payments: $_payments');
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: ShoppingAppBar(
          leading: const AppBackButton(),
          title: const Text('My Payments'),
        ),
        body: Container(
          color: AppColors.cardColor,
          child: FutureBuilder<List<Payment>>(
            future: _payments,
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
  final Payment order;

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
            // Text(
            //   'Items:',
            //   style: const TextStyle(fontWeight: FontWeight.bold),
            // ),
            // ...order.items.map((item) => Padding(
            //       padding: const EdgeInsets.symmetric(vertical: 2),
            //       child: Text(
            //           '${item.productName ?? ''} - Qty: ${item.quantity} - Price: ${item.price}'),
            //     )),
            // if (order.user != null)
            //   Padding(
            //     padding: const EdgeInsets.only(top: 8),
            //     child: Text('User: ${order.user!.name}'),
            //   ),
          ],
        ),
      ),
    );
  }
}
