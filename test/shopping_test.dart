import 'package:flutter_test/flutter_test.dart';
import 'package:yesil_sepet/controllers/controllers.dart';
import 'package:yesil_sepet/core/utils/smart_categorizer.dart';
import 'package:yesil_sepet/data/repositories/mock/mock_shopping_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShoppingController & MockShoppingRepository Tests', () {
    late MockShoppingRepository repository;
    late ShoppingController controller;

    setUp(() {
      repository = MockShoppingRepository();
      controller = ShoppingController(shoppingRepository: repository);
    });

    test('Initial fetchLists loads unique lists', () async {
      await controller.fetchLists('1');
      expect(controller.lists.isNotEmpty, true);
      final ids = controller.lists.map((l) => l.id).toSet();
      expect(ids.length, equals(controller.lists.length),
          reason: 'All list IDs should be unique');
    });

    test('createList creates exactly 1 list and avoids duplicate entries', () async {
      await controller.fetchLists('1');
      final initialCount = controller.lists.length;

      final success = await controller.createList('1', 'Piknik Listesi');
      expect(success, true);
      expect(controller.lists.length, equals(initialCount + 1),
          reason: 'List count must increase by exactly 1');

      // Verify no duplicate IDs
      final ids = controller.lists.map((l) => l.id).toList();
      final uniqueIds = ids.toSet();
      expect(uniqueIds.length, equals(ids.length),
          reason: 'There must be NO duplicate list IDs in controller');

      // Now simulate subsequent fetchLists (like when DashboardScreen opens)
      await controller.fetchLists('1');
      expect(controller.lists.length, equals(initialCount + 1),
          reason: 'Subsequent fetchLists must NOT duplicate the list');

      final idsAfterFetch = controller.lists.map((l) => l.id).toList();
      expect(idsAfterFetch.toSet().length, equals(idsAfterFetch.length),
          reason: 'No duplicates after fetch');
    });

    test('addItem adds item without duplication', () async {
      await controller.fetchLists('1');
      final list = controller.lists.first;
      final initialItemCount = list.items.length;

      final success = await controller.addItem('1', list.id, '2 kg Elma');
      expect(success, true);

      final updatedList = controller.lists.firstWhere((l) => l.id == list.id);
      expect(updatedList.items.length, equals(initialItemCount + 1));

      final itemIds = updatedList.items.map((i) => i.id).toList();
      expect(itemIds.toSet().length, equals(itemIds.length),
          reason: 'No duplicate items inside shopping list');
    });

    test('SmartCategorizer categorizes and extracts quantities correctly', () {
      final res1 = SmartCategorizer.categorize('2 kg elma');
      expect(res1.name, 'Elma');
      expect(res1.category, 'Manav');
      expect(res1.icon, '🍎');
      expect(res1.quantity, '2 kg');

      final res2 = SmartCategorizer.categorize('1 L süt');
      expect(res2.name, 'Süt');
      expect(res2.category, 'Süt Ürünleri');
      expect(res2.icon, '🥛');
      expect(res2.quantity, '1 L');
    });

    test('SmartCategorizer parses multi-item sentence', () {
      final items = SmartCategorizer.parseMultiItemText('2 kg elma, 1 litre süt ve ekmek');
      expect(items.length, 3);
      expect(items[0].name, 'Elma');
      expect(items[1].name, 'Süt');
      expect(items[2].name, 'Ekmek');
    });
  });
}
