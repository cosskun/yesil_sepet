import '../shopping_repository.dart';
import '../../models/app_notification.dart';
import '../../models/list_member.dart';
import '../../models/shopping_item.dart';
import '../../models/shopping_list.dart';
import '../../models/user.dart';

/// In-memory mock implementation of [ShoppingRepository] for offline mode.
class MockShoppingRepository implements ShoppingRepository {
  static final List<ShoppingList> _mockLists = [
    ShoppingList(
      id: '1',
      title: 'Haftalık Market Alışverişi',
      ownerId: '1',
      shareCode: 'abc123',
      members: [const ListMember(id: '1', name: 'Deneme Kullanıcı', isOwner: true)],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      items: [
        const ShoppingItem(id: '101', name: 'Süt (2 Litre)', isBought: false),
        const ShoppingItem(id: '102', name: 'Yumurta (30\'lu)', isBought: true),
        const ShoppingItem(id: '103', name: 'Tam Buğday Ekmeği', isBought: false),
        const ShoppingItem(id: '104', name: 'Zeytin', isBought: false),
      ],
    ),
  ];

  @override
  Future<List<ShoppingList>> getLists(String token) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockLists;
  }

  @override
  Future<ShoppingList> createList(String token, String title) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newList = ShoppingList(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      ownerId: token,
      shareCode: 'code_${DateTime.now().millisecondsSinceEpoch % 10000}',
      members: [ListMember(id: token, name: 'Kullanıcı', isOwner: true)],
      createdAt: DateTime.now(),
      items: [],
    );
    _mockLists.add(newList);
    return newList;
  }

  @override
  Future<bool> deleteList(String token, String listId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _mockLists.removeWhere((l) => l.id == listId);
    return true;
  }

  @override
  Future<ShoppingItem> addItem(
    String token,
    String listId,
    String name, {
    String? category,
    String? icon,
    String? quantity,
    double? price,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newItem = ShoppingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: category ?? 'Diğer',
      icon: icon ?? '🛒',
      quantity: quantity,
      price: price,
      isBought: false,
    );
    final index = _mockLists.indexWhere((l) => l.id == listId);
    if (index != -1) {
      _mockLists[index].items.add(newItem);
    }
    return newItem;
  }

  @override
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
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final listIndex = _mockLists.indexWhere((l) => l.id == listId);
    if (listIndex != -1) {
      final itemIndex =
          _mockLists[listIndex].items.indexWhere((i) => i.id == itemId);
      if (itemIndex != -1) {
        final current = _mockLists[listIndex].items[itemIndex];
        final updated = current.copyWith(
          isBought: isBought ?? current.isBought,
          isArchived: isArchived ?? current.isArchived,
          name: name ?? current.name,
          category: category ?? current.category,
          icon: icon ?? current.icon,
          quantity: quantity ?? current.quantity,
          price: price ?? current.price,
          boughtAt: isBought == true
              ? DateTime.now()
              : (isBought == false ? null : current.boughtAt),
        );
        _mockLists[listIndex].items[itemIndex] = updated;
        return updated;
      }
    }
    throw Exception('Ürün bulunamadı.');
  }

  @override
  Future<bool> deleteItem(String token, String listId, String itemId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final listIndex = _mockLists.indexWhere((l) => l.id == listId);
    if (listIndex != -1) {
      _mockLists[listIndex].items.removeWhere((i) => i.id == itemId);
      return true;
    }
    return false;
  }

  @override
  Future<ShoppingList> archiveItems(String token, String listId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final listIndex = _mockLists.indexWhere((l) => l.id == listId);
    if (listIndex != -1) {
      final list = _mockLists[listIndex];
      final updatedItems = list.items.map((i) {
        if (i.isBought) return i.copyWith(isArchived: true);
        return i;
      }).toList();
      _mockLists[listIndex] = list.copyWith(items: updatedItems);
      return _mockLists[listIndex];
    }
    throw Exception('Liste bulunamadı.');
  }

  @override
  Future<Map<String, dynamic>> getShareInfo(String shareCode) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final list = _mockLists.firstWhere((l) => l.shareCode == shareCode,
        orElse: () => throw Exception('Liste bulunamadı.'));
    return {
      'id': list.id,
      'title': list.title,
      'shareCode': list.shareCode,
      'memberCount': list.members.length,
      'createdAt': list.createdAt.toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>> joinList(String shareCode, String? token) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final list = _mockLists.firstWhere((l) => l.shareCode == shareCode,
        orElse: () => throw Exception('Liste bulunamadı.'));
    final userToken = token ?? 'guest_1';
    final user = User(id: userToken, email: '', name: 'Üye');
    return {
      'token': userToken,
      'user': user.toJson(),
      'list': list.toJson(),
    };
  }

  @override
  Future<List<AppNotification>> getNotifications(String token) async => [];

  @override
  Future<bool> markNotificationsRead(String token) async => true;
}
