import 'dart:convert';
import 'package:html/parser.dart' as html;
import '../models/userModel.dart';

String notificationText(String? content) {
  final fragment = html.parseFragment(content ?? '');
  for (final element in fragment.querySelectorAll('style, script, head')) {
    element.remove();
  }
  for (final element in fragment.querySelectorAll('br')) {
    element.replaceWith(html.parseFragment(' '));
  }
  for (final element
      in fragment.querySelectorAll('p, div, tr, td, h1, h2, h3, li')) {
    element.append(html.parseFragment(' '));
  }
  return (fragment.text ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
}

int? notificationOrderId(NotificationModel notification) {
  dynamic data = notification.data;
  if (data is String) {
    try {
      data = jsonDecode(data);
    } catch (_) {
      data = null;
    }
  }
  if (data is Map) {
    final id = int.tryParse('${data['orderId']}');
    if (id != null && id > 0) return id;
  }
  final content =
      '${notification.name} ${notificationText(notification.remarks)}';
  final match = RegExp(
          r'\border\s+(?:created\s+with\s+|number\s+|#\s*)?(\d+)\b',
          caseSensitive: false)
      .firstMatch(content);
  return match == null ? null : int.tryParse(match.group(1)!);
}
