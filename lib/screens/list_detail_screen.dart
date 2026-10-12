import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/controllers.dart';
import '../models/models.dart';
import '../services/smart_categorizer.dart';

class ListDetailScreen extends StatefulWidget {
  final String listId;
  const ListDetailScreen({super.key, required this.listId});

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> with SingleTickerProviderStateMixin {
  final _itemController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _itemController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addItem(String token, ShoppingController controller) async {
    final name = _itemController.text.trim();
    if (name.isNotEmpty) {
      final success = await controller.addItem(token, widget.listId, name);
      if (success) {
        _itemController.clear();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(controller.errorMessage ?? 'Ürün eklenemedi.'),
              backgroundColor: const Color(0xffff9a9e),
            ),
          );
        }
      }
    }
  }

  void _showAddDetailedItemDialog(String token, ShoppingController controller) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String selectedCat = 'Diğer';
    String selectedIcon = '🛒';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: const Row(
            children: [
              Icon(Icons.add_shopping_cart, color: Color(0xff4a7856)),
              SizedBox(width: 8),
              Expanded(
                child: Text('Detaylı Ürün Ekle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Ürün Adı',
                    hintText: 'Örn: Amasya Elması',
                  ),
                  onChanged: (val) {
                    final catItem = SmartCategorizer.categorize(val);
                    setDlgState(() {
                      selectedCat = catItem.category;
                      selectedIcon = catItem.icon;
                      if (catItem.quantity != null && qtyCtrl.text.isEmpty) {
                        qtyCtrl.text = catItem.quantity!;
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: qtyCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Miktar / Birim',
                          hintText: 'Örn: 2 kg, 3 adet',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Fiyat (₺)',
                          hintText: 'Örn: 45.50',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(selectedIcon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xffe3ece4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Reyon: $selectedCat',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff0f2c1a), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('İptal', style: TextStyle(color: Color(0xff506e5b))),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isNotEmpty) {
                  final price = double.tryParse(priceCtrl.text.replaceAll(',', '.'));
                  final qty = qtyCtrl.text.trim().isNotEmpty ? qtyCtrl.text.trim() : null;
                  final nav = Navigator.of(ctx);

                  await controller.addItem(
                    token,
                    widget.listId,
                    name,
                    category: selectedCat,
                    icon: selectedIcon,
                    quantity: qty,
                    price: price,
                  );
                  if (mounted) nav.pop();
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSmartMultiAddDialog(String token, ShoppingController controller) {
    final inputCtrl = TextEditingController(text: '2 kilo elma, 1 litre süt ve ekmek');
    List<CategorizedItem> previewItems = SmartCategorizer.parseMultiItemText(inputCtrl.text);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: const Row(
            children: [
              Icon(Icons.mic, color: Color(0xff4a7856)),
              SizedBox(width: 8),
              Expanded(
                child: Text('Sesle / Hızlı Çoklu Ekle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cümlenizi söyleyin veya yazın (örn: "2 kilo elma, 1 litre süt ve ekmek"):',
                  style: TextStyle(fontSize: 13, color: Color(0xff506e5b)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: inputCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Cümle veya kelimeleri buraya yazın...',
                  ),
                  onChanged: (val) {
                    setDlgState(() {
                      previewItems = SmartCategorizer.parseMultiItemText(val);
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text('Ayrıştırılan Ürünler:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff0f2c1a))),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xff4a7856),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${previewItems.length} Ürün',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xfff5f9f6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffe3ece4)),
                  ),
                  child: previewItems.isEmpty
                      ? const Center(child: Text('Ayrıştırılacak ürün bulunamadı.', style: TextStyle(color: Color(0xff506e5b), fontSize: 12)))
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: previewItems.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Text(item.icon, style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${item.quantity != null ? "${item.quantity} " : ""}${item.name}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff0f2c1a)),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffe3ece4),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(item.category, style: const TextStyle(fontSize: 10, color: Color(0xff0f2c1a))),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('İptal', style: TextStyle(color: Color(0xff506e5b))),
            ),
            ElevatedButton(
              onPressed: previewItems.isEmpty
                  ? null
                  : () async {
                      final nav = Navigator.of(ctx);
                      final messenger = ScaffoldMessenger.of(context);
                      final count = await controller.addMultipleItems(token, widget.listId, inputCtrl.text);
                      if (mounted) {
                        nav.pop();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('$count ürün otomatik ayrı ayrı eklendi!'),
                            backgroundColor: const Color(0xff4a7856),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
              child: const Text('Tümünü Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleItem(String token, ShoppingController controller, ShoppingItem item) async {
    final nextBoughtState = !item.isBought;
    final success = await controller.updateItem(
      token,
      widget.listId,
      item.id,
      isBought: nextBoughtState,
      isArchived: nextBoughtState,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Ürün güncellenemedi.'),
          backgroundColor: const Color(0xffff9a9e),
        ),
      );
    }
  }

  Future<void> _restoreItem(String token, ShoppingController controller, ShoppingItem item) async {
    final success = await controller.updateItem(
      token,
      widget.listId,
      item.id,
      isBought: false,
      isArchived: false,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${item.name}" yeniden alınacaklar listesine taşındı.'),
          backgroundColor: const Color(0xff4a7856),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final shoppingController = Provider.of<ShoppingController>(context);
    final token = authController.token ?? authController.currentUser?.id ?? 'guest';

    final listIndex = shoppingController.lists.indexWhere((l) => l.id == widget.listId);
    if (listIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Liste Detayı')),
        body: const Center(child: Text('Liste bulunamadı.')),
      );
    }

    final shoppingList = shoppingController.lists[listIndex];
    final activeItems = shoppingList.items.where((i) => !i.isBought).toList();
    final archivedItems = shoppingList.items.where((i) => i.isBought).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20.0),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(shoppingList.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic, color: Color(0xff4a7856)),
            onPressed: () => _showSmartMultiAddDialog(token, shoppingController),
            tooltip: 'Sesle / Çoklu Hızlı Ekle',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xff4a7856),
          labelColor: const Color(0xff0f2c1a),
          unselectedLabelColor: const Color(0xff506e5b),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: 'Alınacaklar (${activeItems.length})'),
            Tab(text: 'Alındı Listesi (${archivedItems.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Alınacaklar
                _buildActiveItemsTab(token, shoppingController, activeItems),

                // TAB 2: Alındı Listesi
                _buildArchivedItemsTab(token, shoppingController, archivedItems),
              ],
            ),
          ),

          // Bottom Budget Summary Bar
          _buildBudgetSummaryBar(shoppingList),
        ],
      ),
    );
  }

  Widget _buildBudgetSummaryBar(ShoppingList shoppingList) {
    final estPrice = shoppingList.totalEstimatedPrice;
    final bghtPrice = shoppingList.totalBoughtPrice;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xff4a7856).withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            )
          ],
          border: const Border(top: BorderSide(color: Color(0xffe3ece4))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Tahmini Toplam Tutar', style: TextStyle(fontSize: 11, color: Color(0xff506e5b)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    '₺${estPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff0f2c1a)),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 32, color: const Color(0xffe3ece4), margin: const EdgeInsets.symmetric(horizontal: 8.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Alınan / Harcanan', style: TextStyle(fontSize: 11, color: Color(0xff506e5b)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    '₺${bghtPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff4a7856)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveItemsTab(String token, ShoppingController controller, List<ShoppingItem> items) {
    // Group items by category
    final Map<String, List<ShoppingItem>> grouped = {};
    for (var item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return Column(
      children: [
        // Quick add bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _itemController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addItem(token, controller),
                  decoration: const InputDecoration(
                    hintText: 'Yeni ürün ekle... (örn: 2 kg Elma)',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              GestureDetector(
                onTap: () => _addItem(token, controller),
                child: Container(
                  height: 48.0,
                  width: 48.0,
                  decoration: BoxDecoration(
                    color: const Color(0xff4a7856),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
              const SizedBox(width: 6.0),
              GestureDetector(
                onTap: () => _showAddDetailedItemDialog(token, controller),
                child: Container(
                  height: 48.0,
                  width: 48.0,
                  decoration: BoxDecoration(
                    color: const Color(0xffe3ece4),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: const Icon(Icons.tune, color: Color(0xff4a7856)),
                ),
              ),
            ],
          ),
        ),

        // Grouped List
        Expanded(
          child: items.isEmpty
              ? _buildEmptyState('Alınacak bir ürün yok.', Icons.check_circle_outline)
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  itemCount: grouped.keys.length,
                  itemBuilder: (context, catIndex) {
                    final category = grouped.keys.elementAt(catIndex);
                    final catItems = grouped[category]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Header
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 12.0, bottom: 6.0),
                          child: Row(
                            children: [
                              Text(catItems.first.icon, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(
                                category,
                                style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Color(0xff0f2c1a)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xffe3ece4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${catItems.length}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xff0f2c1a)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Items under this category
                        ...catItems.map((item) => _buildItemCard(token, controller, item)),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildArchivedItemsTab(String token, ShoppingController controller, List<ShoppingItem> items) {
    return items.isEmpty
        ? _buildEmptyState('Henüz alınan ürün yok.', Icons.shopping_basket_outlined)
        : ListView.builder(
            padding: const EdgeInsets.only(top: 12.0, bottom: 24.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: const Color(0xfff5f9f6),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: const Color(0xffe3ece4)),
                ),
                child: ListTile(
                  leading: Text(item.icon, style: const TextStyle(fontSize: 22)),
                  title: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 15.0,
                      color: Color(0xff506e5b),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: Text(
                    '${item.category}${item.quantity != null ? " • ${item.quantity}" : ""}',
                    style: const TextStyle(fontSize: 12.0, color: Color(0xff506e5b)),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.undo, color: Color(0xff4a7856), size: 20.0),
                    onPressed: () => _restoreItem(token, controller, item),
                    tooltip: 'Yeniden Alınacaklara Taşı',
                  ),
                ),
              );
            },
          );
  }

  Widget _buildItemCard(String token, ShoppingController controller, ShoppingItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        controller.deleteItem(token, widget.listId, item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${item.name}" listeden silindi.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: const Color(0xffffb3a7),
          borderRadius: BorderRadius.circular(12.0),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24.0),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: const Color(0xffe3ece4)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: item.isBought,
                activeColor: const Color(0xff4a7856),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                onChanged: (_) => _toggleItem(token, controller, item),
              ),
              Text(item.icon, style: const TextStyle(fontSize: 22)),
            ],
          ),
          title: Text(
            item.name,
            style: const TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
              color: Color(0xff0f2c1a),
            ),
          ),
          subtitle: item.quantity != null
              ? Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xfff5f9f6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.quantity!,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xff4a7856)),
                  ),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.price != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xffe3ece4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₺${item.price!.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xff0f2c1a)),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xffffb3a7), size: 20.0),
                onPressed: () => controller.deleteItem(token, widget.listId, item.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64.0, color: const Color(0xffe3ece4)),
          const SizedBox(height: 16.0),
          Text(message, style: const TextStyle(fontSize: 15.0, color: Color(0xff506e5b))),
        ],
      ),
    );
  }
}
