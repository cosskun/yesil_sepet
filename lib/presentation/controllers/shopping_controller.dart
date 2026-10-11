import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/config/app_settings.dart';
import '../../core/utils/smart_categorizer.dart';
import '../../data/models/app_notification.dart';
import '../../data/models/shopping_item.dart';
import '../../data/models/shopping_list.dart';
import '../../data/models/user.dart';
import '../../data/repositories/mock/mock_shopping_repository.dart';
import '../../data/repositories/remote/remote_shopping_repository.dart';
import '../../data/repositories/shopping_repository.dart';
import 'auth_controller.dart';

/// State management controller for shopping lists, items, and notifications.
class ShoppingController extends ChangeNotifier {
  final ShoppingRepository? _injectedShoppingRepository;

  List<ShoppingList> _lists = [];
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _pollingTimer;

  ShoppingController({ShoppingRepository? shoppingRepository})
      : _injectedShoppingRepository = shoppingRepository;

  List<ShoppingList> get lists => _lists;
  List<AppNotification> get notifications => _notifications;
  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ShoppingRepository get _shoppingRepository =>
      _injectedShoppingRepository ??
      (AppSettings.isServerSync
          ? RemoteShoppingRepository()
          : MockShoppingRepository());

  void startPolling(String token) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchListsSilent(token);
      fetchNotifications(token);
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }

  /// Deduplicates lists by ID preserving latest updates
  List<ShoppingList> _deduplicateLists(List<ShoppingList> inputLists) {
    final uniqueMap = <String, ShoppingList>{};
    for (var list in inputLists) {
      uniqueMap[list.id] = list;
    }
    return uniqueMap.values.toList();
  }

  Future<void> fetchLists(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _shoppingRepository.getLists(token);
      _lists = _deduplicateLists(fetched);
      _isLoading = false;
      notifyListeners();
      startPolling(token);
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> fetchListsSilent(String token) async {
    try {
      final updatedLists = await _shoppingRepository.getLists(token);
      _lists = _deduplicateLists(updatedLists);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchNotifications(String token) async {
    try {
      final notifs = await _shoppingRepository.getNotifications(token);
      _notifications = notifs;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markNotificationsRead(String token) async {
    try {
      await _shoppingRepository.markNotificationsRead(token);
      _notifications = [];
      notifyListeners();
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> getShareInfo(String shareCode) async {
    try {
      return await _shoppingRepository.getShareInfo(shareCode);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<ShoppingList?> joinList(
      String shareCode, AuthController authController) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result =
          await _shoppingRepository.joinList(shareCode, authController.token);
      final userObj = User.fromJson(result['user']);
      final listObj = ShoppingList.fromJson(result['list']);

      authController.setGuestUser(userObj);

      final index = _lists.indexWhere((l) => l.id == listObj.id);
      if (index != -1) {
        _lists[index] = listObj;
      } else {
        _lists.add(listObj);
      }

      _isLoading = false;
      notifyListeners();

      if (authController.token != null) {
        startPolling(authController.token!);
      }

      return listObj;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  String _capitalizeTitle(String text) {
    if (text.trim().isEmpty) return '';
    return text.trim().split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  Future<bool> createList(String token, String title) async {
    try {
      final formattedTitle = _capitalizeTitle(title);
      final newList =
          await _shoppingRepository.createList(token, formattedTitle);

      // Check if list already exists in _lists to prevent duplicate entries
      final existingIndex = _lists.indexWhere((l) => l.id == newList.id);
      if (existingIndex != -1) {
        _lists[existingIndex] = newList;
      } else {
        _lists.add(newList);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteList(String token, String listId) async {
    try {
      final success = await _shoppingRepository.deleteList(token, listId);
      if (success) {
        _lists.removeWhere((l) => l.id == listId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> addItem(
    String token,
    String listId,
    String rawName, {
    String? category,
    String? icon,
    String? quantity,
    double? price,
  }) async {
    try {
      final catItem = SmartCategorizer.categorize(rawName);
      final finalName =
          _capitalizeTitle(catItem.name.isNotEmpty ? catItem.name : rawName);
      final finalCat = category ?? catItem.category;
      final finalIcon = icon ?? catItem.icon;
      final finalQty = quantity ?? catItem.quantity;

      final newItem = await _shoppingRepository.addItem(
        token,
        listId,
        finalName,
        category: finalCat,
        icon: finalIcon,
        quantity: finalQty,
        price: price,
      );

      final listIndex = _lists.indexWhere((l) => l.id == listId);
      if (listIndex != -1) {
        final list = _lists[listIndex];
        final itemIndex = list.items.indexWhere((i) => i.id == newItem.id);
        final updatedItems = List<ShoppingItem>.from(list.items);
        if (itemIndex != -1) {
          updatedItems[itemIndex] = newItem;
        } else {
          updatedItems.add(newItem);
        }
        _lists[listIndex] = list.copyWith(items: updatedItems);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<int> addMultipleItems(
      String token, String listId, String inputSentence) async {
    final parsedList = SmartCategorizer.parseMultiItemText(inputSentence);
    int count = 0;
    for (var item in parsedList) {
      final success = await addItem(
        token,
        listId,
        item.name,
        category: item.category,
        icon: item.icon,
        quantity: item.quantity,
      );
      if (success) count++;
    }
    return count;
  }

  Future<bool> toggleItem(
      String token, String listId, String itemId, bool isBought) async {
    return updateItem(token, listId, itemId, isBought: isBought);
  }

  Future<bool> updateItem(
    String token,
    String listId,
    String itemId, {
    bool? isBought,
    bool? isArchived,
    String? name,
  }) async {
    try {
      final updatedItem = await _shoppingRepository.updateItem(
        token,
        listId,
        itemId,
        isBought: isBought,
        isArchived: isArchived,
        name: name,
      );
      final listIndex = _lists.indexWhere((l) => l.id == listId);
      if (listIndex != -1) {
        final list = _lists[listIndex];
        final itemIndex = list.items.indexWhere((i) => i.id == itemId);
        if (itemIndex != -1) {
          final updatedItems = List<ShoppingItem>.from(list.items);
          updatedItems[itemIndex] = updatedItem;
          _lists[listIndex] = list.copyWith(items: updatedItems);
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteItem(String token, String listId, String itemId) async {
    try {
      final success =
          await _shoppingRepository.deleteItem(token, listId, itemId);
      if (success) {
        final listIndex = _lists.indexWhere((l) => l.id == listId);
        if (listIndex != -1) {
          final list = _lists[listIndex];
          final updatedItems = List<ShoppingItem>.from(list.items)
            ..removeWhere((i) => i.id == itemId);
          _lists[listIndex] = list.copyWith(items: updatedItems);
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> archiveItems(String token, String listId) async {
    try {
      final updatedList =
          await _shoppingRepository.archiveItems(token, listId);
      final listIndex = _lists.indexWhere((l) => l.id == listId);
      if (listIndex != -1) {
        _lists[listIndex] = updatedList;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
