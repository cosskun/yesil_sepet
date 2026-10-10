import 'dart:convert';
import 'package:http/http.dart' as http;
import '../shopping_repository.dart';
import '../../models/app_notification.dart';
import '../../models/shopping_item.dart';
import '../../models/shopping_list.dart';
import '../../../core/config/app_settings.dart';

/// Remote HTTP API implementation of [ShoppingRepository] for server sync mode.
class RemoteShoppingRepository implements ShoppingRepository {
  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  @override
  Future<List<ShoppingList>> getLists(String token) async {
    final response = await http.get(
      Uri.parse('${AppSettings.serverUrl}/api/shopping/lists'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      final responseBody = jsonDecode(response.body);
      throw Exception(responseBody['error'] ?? 'Listeler alınamadı.');
    }

    final List rawLists = jsonDecode(response.body);
    return rawLists.map((l) => ShoppingList.fromJson(l)).toList();
  }

  @override
  Future<ShoppingList> createList(String token, String title) async {
    final response = await http.post(
      Uri.parse('${AppSettings.serverUrl}/api/shopping/lists'),
      headers: _headers(token),
      body: jsonEncode({'title': title}),
    );

    final responseBody = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(responseBody['error'] ?? 'Liste oluşturulamadı.');
    }

    return ShoppingList.fromJson(responseBody);
  }

  @override
  Future<bool> deleteList(String token, String listId) async {
    final response = await http.delete(
      Uri.parse('${AppSettings.serverUrl}/api/shopping/lists/$listId'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      final responseBody = jsonDecode(response.body);
      throw Exception(responseBody['error'] ?? 'Liste silinemedi.');
    }
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
    final Map<String, dynamic> bodyData = {'name': name};
    if (category != null) bodyData['category'] = category;
    if (icon != null) bodyData['icon'] = icon;
    if (quantity != null) bodyData['quantity'] = quantity;
    if (price != null) bodyData['price'] = price;

    final response = await http.post(
      Uri.parse('${AppSettings.serverUrl}/api/shopping/lists/$listId/items'),
      headers: _headers(token),
      body: jsonEncode(bodyData),
    );

    final responseBody = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(responseBody['error'] ?? 'Ürün eklenemedi.');
    }

    return ShoppingItem.fromJson(responseBody);
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
    final Map<String, dynamic> updateFields = {};
    if (isBought != null) updateFields['isBought'] = isBought;
    if (isArchived != null) updateFields['isArchived'] = isArchived;
    if (name != null) updateFields['name'] = name;
    if (category != null) updateFields['category'] = category;
    if (icon != null) updateFields['icon'] = icon;
    if (quantity != null) updateFields['quantity'] = quantity;
    if (price != null) updateFields['price'] = price;

    final response = await http.put(
      Uri.parse('${AppSettings.serverUrl}/api/shopping/lists/$listId/items/$itemId'),
      headers: _headers(token),
      body: jsonEncode(updateFields),
    );

    final responseBody = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(responseBody['error'] ?? 'Ürün güncellenemedi.');
    }

    return ShoppingItem.fromJson(responseBody);
  }

  @override
  Future<bool> deleteItem(String token, String listId, String itemId) async {
    final response = await http.delete(
      Uri.parse('${AppSettings.serverUrl}/api/shopping/lists/$listId/items/$itemId'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      final responseBody = jsonDecode(response.body);
      throw Exception(responseBody['error'] ?? 'Ürün silinemedi.');
    }
    return true;
  }

  @override
  Future<ShoppingList> archiveItems(String token, String listId) async {
    final response = await http.post(
      Uri.parse('${AppSettings.serverUrl}/api/shopping/lists/$listId/archive'),
      headers: _headers(token),
    );

    final responseBody = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(responseBody['error'] ?? 'Ürünler arşivlenemedi.');
    }

    return ShoppingList.fromJson(responseBody);
  }

  @override
  Future<Map<String, dynamic>> getShareInfo(String shareCode) async {
    final response = await http.get(
      Uri.parse('${AppSettings.serverUrl}/api/shopping/share/$shareCode'),
      headers: {'Content-Type': 'application/json'},
    );

    final responseBody = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(responseBody['error'] ?? 'Liste bilgisi alınamadı.');
    }
    return responseBody;
  }

  @override
  Future<Map<String, dynamic>> joinList(String shareCode, String? token) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.post(
      Uri.parse('${AppSettings.serverUrl}/api/shopping/join/$shareCode'),
      headers: headers,
    );

    final responseBody = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(responseBody['error'] ?? 'Listeye katılım başarısız.');
    }
    return responseBody;
  }

  @override
  Future<List<AppNotification>> getNotifications(String token) async {
    final response = await http.get(
      Uri.parse('${AppSettings.serverUrl}/api/notifications'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      return [];
    }

    final List raw = jsonDecode(response.body);
    return raw.map((n) => AppNotification.fromJson(n)).toList();
  }

  @override
  Future<bool> markNotificationsRead(String token) async {
    final response = await http.put(
      Uri.parse('${AppSettings.serverUrl}/api/notifications/read'),
      headers: _headers(token),
    );
    return response.statusCode == 200;
  }
}
