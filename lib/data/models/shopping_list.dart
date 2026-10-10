import 'list_member.dart';
import 'shopping_item.dart';

/// Shopping list aggregate entity containing items, members, and budget calculations.
class ShoppingList {
  final String id;
  final String title;
  final String ownerId;
  final String shareCode;
  final List<ListMember> members;
  final DateTime createdAt;
  final List<ShoppingItem> items;

  const ShoppingList({
    required this.id,
    required this.title,
    required this.ownerId,
    this.shareCode = '',
    this.members = const [],
    required this.createdAt,
    required this.items,
  });

  int get boughtCount => items.where((i) => i.isBought && !i.isArchived).length;
  int get activeCount => items.where((i) => !i.isBought && !i.isArchived).length;
  int get archivedCount => items.where((i) => i.isArchived).length;
  int get totalActiveCount => items.where((i) => !i.isArchived).length;
  int get memberCount => members.isNotEmpty ? members.length : 1;

  double get totalEstimatedPrice {
    double total = 0.0;
    for (var i in items) {
      if (!i.isArchived && i.price != null) {
        total += i.price!;
      }
    }
    return total;
  }

  double get totalBoughtPrice {
    double total = 0.0;
    for (var i in items) {
      if (!i.isArchived && i.isBought && i.price != null) {
        total += i.price!;
      }
    }
    return total;
  }

  ShoppingList copyWith({
    String? id,
    String? title,
    String? ownerId,
    String? shareCode,
    List<ListMember>? members,
    DateTime? createdAt,
    List<ShoppingItem>? items,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      title: title ?? this.title,
      ownerId: ownerId ?? this.ownerId,
      shareCode: shareCode ?? this.shareCode,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] as List? ?? [];
    var rawMembers = json['members'] as List? ?? [];
    return ShoppingList(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      ownerId: json['ownerId']?.toString() ?? '',
      shareCode: json['shareCode']?.toString() ?? '',
      members: rawMembers.map((m) => ListMember.fromJson(m)).toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      items: rawItems.map((item) => ShoppingItem.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'ownerId': ownerId,
      'shareCode': shareCode,
      'members': members.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
