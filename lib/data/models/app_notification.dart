/// Represents an in-app notification for shared list updates.
class AppNotification {
  final String id;
  final String listId;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.listId,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      listId: json['listId']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] == true,
    );
  }
}
