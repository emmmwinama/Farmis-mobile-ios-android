class AppNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? link;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.link,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        type: json['type'] as String? ?? 'general',
        title: json['title'] as String? ?? 'Notification',
        message: json['message'] as String? ?? '',
        isRead: json['isRead'] as bool? ?? false,
        link: json['link'] as String?,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class NotificationsData {
  final List<AppNotification> notifications;
  final int unread;

  const NotificationsData({required this.notifications, required this.unread});

  factory NotificationsData.fromJson(Map<String, dynamic> json) =>
      NotificationsData(
        notifications: (json['notifications'] as List? ?? const [])
            .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
            .toList(),
        unread: (json['unread'] as num? ?? 0).toInt(),
      );
}
