import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/controllers.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'settings_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                final nav = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final authController = Provider.of<AuthController>(context, listen: false);
                final shoppingController = Provider.of<ShoppingController>(context, listen: false);
                final success = await shoppingController.createList(authController.token!, title);
                if (mounted) {
                  nav.pop();
                  if (success) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('"$title" listesi başarıyla oluşturuldu.'),
                        backgroundColor: const Color(0xff5eaa82),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    nav.push(
                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                    );
                  } else {
                    messenger.showSnackBar(
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

  void _showProfileInfo(BuildContext context, String name, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        backgroundColor: Colors.white,
        title: const Text(
          'Profil Bilgileri',
          style: TextStyle(color: Color(0xff1c3d2b), fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline, color: Color(0xff5eaa82)),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text('İsim: $name', style: const TextStyle(color: Color(0xff1c3d2b), fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                const Icon(Icons.email_outlined, color: Color(0xff5eaa82)),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text('E-posta: ${email.isNotEmpty ? email : "Davetli Üye"}', style: const TextStyle(color: Color(0xff1c3d2b))),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (_) => const SettingsDialog(),
              );
            },
            icon: const Icon(Icons.settings_outlined, size: 16.0),
            label: const Text('Bağlantı Ayarları'),
            style: TextButton.styleFrom(foregroundColor: const Color(0xff5a7a68)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat', style: TextStyle(color: Color(0xff5eaa82), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showNotificationsSheet(String token, ShoppingController shoppingController) {
    final notifications = shoppingController.notifications;
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
                const Text(
                  'Bildirimler',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Color(0xff0f2c1a)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    shoppingController.markNotificationsRead(token);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            notifications.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(
                      child: Text('Henüz okunmamış bildiriminiz yok.', style: TextStyle(color: Color(0xff506e5b))),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const Divider(color: Color(0xffe3ece4)),
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xffe3ece4),
                          child: Icon(Icons.notifications_active_outlined, color: Color(0xff4a7856), size: 20.0),
                        ),
                        title: Text(n.message, style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: Color(0xff0f2c1a))),
                        subtitle: Text(
                          '${n.createdAt.hour.toString().padLeft(2, '0')}:${n.createdAt.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 12.0, color: Color(0xff506e5b)),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    ).then((_) {
      shoppingController.markNotificationsRead(token);
    });
  }

  void _logout() {
    Provider.of<AuthController>(context, listen: false).logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final shoppingController = Provider.of<ShoppingController>(context);
    final user = authController.currentUser;

    int pendingItemsCount = 0;
    for (var list in shoppingController.lists) {
      pendingItemsCount += list.items.where((i) => !i.isBought).length;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeşil Sepet'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Color(0xff4a7856)),
                onPressed: authController.token != null
                    ? () => _showNotificationsSheet(authController.token!, shoppingController)
                    : null,
                tooltip: 'Bildirimler',
              ),
              if (shoppingController.unreadNotificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: const BoxDecoration(
                      color: Color(0xffffb3a7),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${shoppingController.unreadNotificationCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xff4a7856)),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const SettingsDialog(),
            ),
            tooltip: 'Bağlantı Ayarları',
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Color(0xffffb3a7)),
            onPressed: _logout,
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Merhaba, ${user?.name ?? "Kullanıcı"} 👋',
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1c3d2b),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        const Text(
                          'Bugün ne alıyoruz?',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Color(0xff5a7a68),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  GestureDetector(
                    onTap: () => _showProfileInfo(context, user?.name ?? 'Kullanıcı', user?.email ?? 'eposta'),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                        color: Color(0xffe8f6f0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco,
                        color: Color(0xff5eaa82),
                        size: 28.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // Summary Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff5eaa82), Color(0xff7bc39c)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff5eaa82).withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alışveriş Özeti',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(child: _buildSummaryStat('Listelerim', '${shoppingController.lists.length} Liste')),
                        Container(width: 1, height: 40, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 12.0)),
                        Expanded(child: _buildSummaryStat('Alınacak Ürünler', '$pendingItemsCount Ürün')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),

              const Text(
                'Hızlı İşlemler',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1c3d2b),
                ),
              ),
              const SizedBox(height: 16.0),

              // Action grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.18,
                children: [
                  _buildActionCard(
                    icon: Icons.list_alt_outlined,
                    title: 'Listelerim',
                    subtitle: 'Alışveriş listelerini gör',
                    color: const Color(0xff5eaa82),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const DashboardScreen()),
                      );
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.add_circle_outline,
                    title: 'Yeni Liste Aç',
                    subtitle: 'Hızlıca ekle',
                    color: const Color(0xffa8e6cf),
                    onTap: _showAddListDialog,
                  ),
                  _buildActionCard(
                    icon: Icons.check_circle_outline,
                    title: 'Alınan Ürünler',
                    subtitle: 'Tamamlanan alışverişler',
                    color: const Color(0xffdcecdd),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const DashboardScreen()),
                      );
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.person_outline,
                    title: 'Profil Bilgim',
                    subtitle: 'Hesap detayları',
                    color: const Color(0xfff4fbf7),
                    onTap: () => _showProfileInfo(context, user?.name ?? 'Kullanıcı', user?.email ?? 'eposta'),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),

              // Tip card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xfff4fbf7),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: const Color(0x335eaa82)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Color(0xff5eaa82)),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        'Yeşil Sepet İpucu: Planlı alışveriş yapmak gereksiz harcamaları %25 oranında azaltır!',
                        style: TextStyle(fontSize: 12.5, color: Color(0xff5a7a68), height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xffe8f6f0),
            fontSize: 12.0,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = color.computeLuminance() < 0.5;
    return Card(
      margin: EdgeInsets.zero,
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 28.0,
                color: isDark ? Colors.white : const Color(0xff1c3d2b),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xff1c3d2b),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.0,
                      color: isDark ? Colors.white70 : const Color(0xff5a7a68),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
