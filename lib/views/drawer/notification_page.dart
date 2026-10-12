import 'package:flutter/material.dart';
import '../../core/components/shopping_app_bar.dart';
import '../../core/constants/apiCall.dart';
import '../../core/constants/apiClients.dart';
import '../../core/models/userModel.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/notification_content.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});
  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  List<NotificationModel> notifications = [];
  final Set<int> readIds = {};
  bool loading = true, failed = false;
  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    try {
      final result = await getNotifications();
      if (mounted) {
        setState(() {
          notifications = result;
          failed = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => failed = true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> open(NotificationModel notification) async {
    if (!notification.readStatus && !readIds.contains(notification.id)) {
      final success = await readNotification(notification.id);
      if (success && mounted) setState(() => readIds.add(notification.id));
    }
    if (!mounted) return;
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                NotificationDetailsPage(notification: notification)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: ShoppingAppBar(title: const Text('Notifications')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : failed
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('We could not load your notifications.'),
                  TextButton(onPressed: refresh, child: const Text('Try again'))
                ]))
              : notifications.isEmpty
                  ? const Center(child: Text('You’re all caught up'))
                  : RefreshIndicator(
                      onRefresh: refresh,
                      child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final n = notifications[index];
                            final read = n.readStatus || readIds.contains(n.id);
                            return Card(
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: const BorderSide(
                                        color: Color(0xFFE3EAE5))),
                                child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: CircleAvatar(
                                        backgroundColor: read
                                            ? const Color(0xFFF0F4F1)
                                            : const Color(0xFFE0F4E8),
                                        child: Icon(
                                            read
                                                ? Icons.notifications_none
                                                : Icons
                                                    .notifications_active_outlined,
                                            color: const Color(0xFF168345))),
                                    title: Text(n.name,
                                        style: TextStyle(
                                            fontWeight: read
                                                ? FontWeight.w500
                                                : FontWeight.w700)),
                                    subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(notificationText(n.remarks),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis)),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () => open(n)));
                          })));
}

class NotificationDetailsPage extends StatefulWidget {
  const NotificationDetailsPage({super.key, required this.notification});
  final NotificationModel notification;
  @override
  State<NotificationDetailsPage> createState() =>
      _NotificationDetailsPageState();
}

class _NotificationDetailsPageState extends State<NotificationDetailsPage> {
  bool opening = false;
  Future<void> openOrder(int id) async {
    if (opening) return;
    setState(() => opening = true);
    try {
      final response = await ApiClient.dio
          .get('/orders/filter', queryParameters: {'orderId': id});
      final order =
          Order.fromJson(Map<String, dynamic>.from(response.data['data']));
      if (!mounted) return;
      await Navigator.pushNamed(context, AppRoutes.orderView, arguments: order);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'We could not open this order. Please try again from My orders.')));
      }
    } finally {
      if (mounted) setState(() => opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.notification;
    final id = notificationOrderId(n);
    return Scaffold(
        appBar: ShoppingAppBar(title: const Text('Notification')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          Text(n.name,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('${n.createdAt.day}/${n.createdAt.month}/${n.createdAt.year}',
              style: const TextStyle(color: Colors.grey)),
          const Divider(height: 32),
          SelectableText(notificationText(n.remarks)),
          if (id != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
                onPressed: opening ? null : () => openOrder(id),
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text(opening ? 'Opening order…' : 'View order #$id'))
          ]
        ]));
  }
}
