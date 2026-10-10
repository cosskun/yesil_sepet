import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/controllers.dart';
import '../models/models.dart';
import 'list_detail_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final authController = Provider.of<AuthController>(context, listen: false);
    final shoppingController = Provider.of<ShoppingController>(context, listen: false);
    if (authController.token != null) {
      shoppingController.fetchLists(authController.token!);
    }
  }

  void _showAddListDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        backgroundColor: Colors.white,
        title: const Text(
          'Yeni Alışveriş Listesi',
          style: TextStyle(color: Color(0xff1c3d2b), fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Örn: Haftalık Market, Piknik Listesi',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal', style: TextStyle(color: Color(0xff5a7a68))),
          ),
          TextButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                final authController = Provider.of<AuthController>(context, listen: false);
                final shoppingController = Provider.of<ShoppingController>(context, listen: false);
                final success = await shoppingController.createList(authController.token!, title);
                if (mounted) {
                  Navigator.of(context).pop();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('"$title" listesi başarıyla oluşturuldu.'),
                        backgroundColor: const Color(0xff5eaa82),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(shoppingController.errorMessage ?? 'Liste oluşturulamadı.'),
                        backgroundColor: const Color(0xffff9a9e),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Oluştur', style: TextStyle(color: Color(0xff5eaa82), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(ShoppingList list) {
    final baseUrl = Uri.base.origin;
    final shareUrl = '$baseUrl/#/join/${list.shareCode}';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Listeyi Paylaş',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              'Bu bağlantıyı paylaşarak başkalarının "${list.title}" listesine üye olmadan katılmasını sağlayabilirsiniz.',
              style: const TextStyle(fontSize: 13.0, color: Color(0xff506e5b)),
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: const Color(0xfff5f9f6),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: const Color(0xffe3ece4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, color: Color(0xff4a7856)),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      shareUrl,
                      style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Color(0xff0f2c1a)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: shareUrl));
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Paylaşım linki panoya kopyalandı!'),
                          backgroundColor: Color(0xff4a7856),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 18.0),
                    label: const Text('Linki Kopyala'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final shoppingController = Provider.of<ShoppingController>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20.0),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Yeşil Sepetim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _loadData,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: SafeArea(
        child: shoppingController.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xff4a7856)))
            : shoppingController.lists.isEmpty
                ? _buildEmptyState()
                : _buildListItems(shoppingController, authController),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddListDialog,
        backgroundColor: const Color(0xff4a7856),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: const Icon(Icons.add, size: 28.0),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Color(0xffe3ece4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 72.0,
                color: Color(0xff4a7856),
              ),
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Henüz Liste Yok',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xff0f2c1a)),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Alışverişe çıkmadan önce ilk listenizi oluşturarak hemen başlayabilirsiniz.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.0, color: Color(0xff506e5b)),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton.icon(
              onPressed: _showAddListDialog,
              icon: const Icon(Icons.add),
              label: const Text('İlk Listenizi Oluşturun'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItems(ShoppingController shoppingController, AuthController authController) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 12.0, bottom: 88.0),
      itemCount: shoppingController.lists.length,
      itemBuilder: (context, index) {
        final list = shoppingController.lists[index];
        final totalCount = list.totalActiveCount;
        final boughtCount = list.boughtCount;
        final progress = totalCount > 0 ? boughtCount / totalCount : 0.0;

        return Card(
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ListDetailScreen(listId: list.id),
                ),
              );
            },
            borderRadius: BorderRadius.circular(24.0),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          list.title,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0f2c1a),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: progress == 1.0 && totalCount > 0
                              ? const Color(0xffe3ece4)
                              : const Color(0xfff5f9f6),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: progress == 1.0 && totalCount > 0
                                ? const Color(0xff4a7856).withOpacity(0.3)
                                : const Color(0xffe3ece4),
                          ),
                        ),
                        child: Text(
                          progress == 1.0 && totalCount > 0
                              ? 'Tamamlandı'
                              : '$boughtCount / $totalCount Alındı',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            color: progress == 1.0 && totalCount > 0
                                ? const Color(0xff4a7856)
                                : const Color(0xff506e5b),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8.0,
                      backgroundColor: const Color(0xffe3ece4),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress == 1.0 && totalCount > 0
                            ? const Color(0xff4a7856)
                            : const Color(0xffbce3c5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${list.createdAt.day}.${list.createdAt.month}.${list.createdAt.year}',
                        style: const TextStyle(fontSize: 12.0, color: Color(0xff506e5b)),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Member count badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: const Color(0xffe2d4f0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.people_outline, size: 14.0, color: Color(0xff0f2c1a)),
                                const SizedBox(width: 4.0),
                                Text(
                                  '${list.memberCount}',
                                  style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: Color(0xff0f2c1a)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          // Share icon
                          IconButton(
                            icon: const Icon(Icons.share_outlined, size: 20.0, color: Color(0xff4a7856)),
                            onPressed: () => _showShareDialog(list),
                            tooltip: 'Paylaş',
                          ),
                          // Delete icon
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20.0, color: Color(0xffffb3a7)),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                  title: const Text('Listeyi Sil', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff0f2c1a))),
                                  content: Text('"${list.title}" listesini silmek istediğinize emin misiniz?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('İptal', style: TextStyle(color: Color(0xff506e5b))),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        shoppingController.deleteList(authController.token!, list.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('"${list.title}" listesi silindi.'),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      child: const Text('Sil', style: TextStyle(color: Color(0xffffb3a7), fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            tooltip: 'Sil',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
