import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/controllers.dart';
import 'list_detail_screen.dart';
import 'home_screen.dart';

class JoinScreen extends StatefulWidget {
  final String shareCode;
  const JoinScreen({super.key, required this.shareCode});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  Map<String, dynamic>? _shareInfo;
  bool _isLoadingInfo = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadShareInfo();
  }

  Future<void> _loadShareInfo() async {
    final shoppingController = Provider.of<ShoppingController>(context, listen: false);
    final info = await shoppingController.getShareInfo(widget.shareCode);
    if (mounted) {
      setState(() {
        _shareInfo = info;
        _isLoadingInfo = false;
        if (info == null) {
          _error = shoppingController.errorMessage ?? 'Liste bulunamadı veya bağlantı geçersiz.';
        }
      });
    }
  }

  Future<void> _handleJoin() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final shoppingController = Provider.of<ShoppingController>(context, listen: false);

    final list = await shoppingController.joinList(widget.shareCode, authController);
    if (mounted) {
      if (list != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ListDetailScreen(listId: list.id)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(shoppingController.errorMessage ?? 'Listeye katılım başarısız oldu.'),
            backgroundColor: const Color(0xffffb3a7),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shoppingController = Provider.of<ShoppingController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste Daveti'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: _isLoadingInfo
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xff4a7856)),
                      SizedBox(height: 16.0),
                      Text('Davet bilgisi yükleniyor...'),
                    ],
                  )
                : _error != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64.0, color: Color(0xffffb3a7)),
                          const SizedBox(height: 16.0),
                          Text(_error!, style: const TextStyle(fontSize: 16.0, color: Color(0xff0f2c1a))),
                          const SizedBox(height: 24.0),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const HomeScreen()),
                              );
                            },
                            child: const Text('Ana Sayfaya Dön'),
                          ),
                        ],
                      )
                    : Container(
                        constraints: const BoxConstraints(maxWidth: 420),
                        padding: const EdgeInsets.all(28.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28.0),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff4a7856).withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            )
                          ],
                          border: Border.all(color: const Color(0xffe3ece4), width: 1.5),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20.0),
                              decoration: const BoxDecoration(
                                color: Color(0xffe3ece4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.group_add_outlined,
                                size: 52.0,
                                color: Color(0xff4a7856),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            const Text(
                              'Bir Alışveriş Listesine Davet Edildiniz!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff0f2c1a),
                              ),
                            ),
                            const SizedBox(height: 16.0),

                            // List info card
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: const Color(0xfff5f9f6),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _shareInfo?['title'] ?? 'Alışveriş Listesi',
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff4a7856),
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.people_outline, size: 18.0, color: Color(0xff506e5b)),
                                      const SizedBox(width: 6.0),
                                      Flexible(
                                        child: Text(
                                          'Mevcut Üye Sayısı: ${_shareInfo?['memberCount'] ?? 1}',
                                          style: const TextStyle(fontSize: 13.0, color: Color(0xff506e5b)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28.0),

                            // Join button (No input required!)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: shoppingController.isLoading ? null : _handleJoin,
                                icon: shoppingController.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Icon(Icons.check_circle_outline),
                                label: Text(shoppingController.isLoading ? 'Katılınıyor...' : 'Listeye Katıl'),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}
