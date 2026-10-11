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
    await Future.delayed(const Duration(milliseconds: 300));
    // Always return a defensive copy so mutations don't alter internal list structure directly
    return _mockLists
        .map((l) => l.copyWith(
              items: List<ShoppingItem>.from(l.items),
              members: List<ListMember>.from(l.members),
            ))
        .toList();
  }

  @override
  Future<ShoppingList> createList(String token, String title) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newList = ShoppingList(
      id: newId,
      title: title,
      ownerId: token,
      shareCode: 'code_${DateTime.now().millisecondsSinceEpoch % 10000}',
      members: [ListMember(id: token, name: 'Kullanıcı', isOwner: true)],
      createdAt: DateTime.now(),
      items: [],
    );

    // Prevent duplicate entries by id
    final existingIdx = _mockLists.indexWhere((l) => l.id == newList.id);
    if (existingIdx != -1) {
      _mockLists[existingIdx] = newList;
    } else {
      _mockLists.add(newList);
    }
    return newList;
  }

  @override
  Future<bool> deleteList(String token, String listId) async {
    await Future.delayed(const Duration(milliseconds: 300));
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
    await Future.delayed(const Duration(milliseconds: 250));
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
      final list = _mockLists[index];
      final itemIdx = list.items.indexWhere((i) => i.id == newItem.id);
      final updatedItems = List<ShoppingItem>.from(list.items);
      if (itemIdx != -1) {
        updatedItems[itemIdx] = newItem;
      } else {
        updatedItems.add(newItem);
      }
      _mockLists[index] = list.copyWith(items: updatedItems);
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
        final updatedItems = List<ShoppingItem>.from(_mockLists[listIndex].items);
        updatedItems[itemIndex] = updated;
        _mockLists[listIndex] = _mockLists[listIndex].copyWith(items: updatedItems);
        return updated;
      }
    }
    throw Exception('Ürün bulunamadı.');
  }

  @override
  Future<bool> deleteItem(String token, String listId, String itemId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final listIndex = _mockLists.indexWhere((l) => l.id == listId);
    if (listIndex != -1) {
      final list = _mockLists[listIndex];
      final updatedItems = List<ShoppingItem>.from(list.items)
        ..removeWhere((i) => i.id == itemId);
      _mockLists[listIndex] = list.copyWith(items: updatedItems);
      return true;
    }
    return false;
  }

  @override
  Future<ShoppingList> archiveItems(String token, String listId) async {
    await Future.delayed(const Duration(milliseconds: 250));
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
    await Future.delayed(const Duration(milliseconds: 250));
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
    await Future.delayed(const Duration(milliseconds: 250));
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
