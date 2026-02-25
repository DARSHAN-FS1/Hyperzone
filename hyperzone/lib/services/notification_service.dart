import 'package:flutter/foundation.dart';

class AppNotification {
  final String title;
  final String message;
  final DateTime createdAt;

  AppNotification({
    required this.title,
    required this.message,
    required this.createdAt,
  });
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final List<AppNotification> _items = [];
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  List<AppNotification> get items => List.unmodifiable(_items);

  void addNotification(String title, String message) {
    _items.insert(
      0,
      AppNotification(
        title: title,
        message: message,
        createdAt: DateTime.now(),
      ),
    );
    unreadCount.value = unreadCount.value + 1;
  }

  void markAllRead() {
    unreadCount.value = 0;
  }
}
