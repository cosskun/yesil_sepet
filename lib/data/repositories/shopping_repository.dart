import '../models/app_notification.dart';
import '../models/shopping_item.dart';
import '../models/shopping_list.dart';

/// Abstract contract for shopping list and item data operations.
abstract class ShoppingRepository {
  Future<List<ShoppingList>> getLists(String token);
  Future<ShoppingList> createList(String token, String title);
  Future<bool> deleteList(String token, String listId);
  Future<ShoppingItem> addItem(
    String token,
    String listId,
    String name, {
    String? category,
    String? icon,
    String? quantity,
    double? price,
  });
  Future<ShoppingItem> updateItem(
    String token,
    String listId,
    String itemId, {
    bool? isBought,
    bool? isArchived,
    String? name,
    String? category,
    String? icon,
    String? quantity,
    double? price,
  });
  Future<bool> deleteItem(String token, String listId, String itemId);
  Future<ShoppingList> archiveItems(String token, String listId);
  Future<Map<String, dynamic>> getShareInfo(String shareCode);
  Future<Map<String, dynamic>> joinList(String shareCode, String? token);
  Future<List<AppNotification>> getNotifications(String token);
  Future<bool> markNotificationsRead(String token);
}
