import 'package:flutter/material.dart';
import '../services/repositories.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool _isSyncEnabled;
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _isSyncEnabled = AppSettings.isServerSync;
    _urlController = TextEditingController(text: AppSettings.serverUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _save() {
    setState(() {
      AppSettings.isServerSync = _isSyncEnabled;
      AppSettings.serverUrl = _urlController.text.trim();
    });
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      backgroundColor: Colors.white,
      title: const Row(
        children: [
          Icon(Icons.settings_outlined, color: Color(0xff5eaa82)),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              'Bağlantı Ayarları',
              style: TextStyle(
                color: Color(0xff1c3d2b),
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Switch for Server Sync
            SwitchListTile(
              title: const Text(
                'Sunucu Senkronizasyonu',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                  color: Color(0xff1c3d2b),
                ),
              ),
              subtitle: const Text(
                'Açıldığında listeleri yerel ağdaki sunucuya kaydeder.',
                style: TextStyle(fontSize: 12.0, color: Color(0xff5a7a68)),
              ),
              value: _isSyncEnabled,
              activeThumbColor: const Color(0xff5eaa82),
              activeTrackColor: const Color(0xffa8e6cf).withValues(alpha: 0.5),
              inactiveThumbColor: const Color(0xff5a7a68),
              contentPadding: EdgeInsets.zero,
              onChanged: (bool value) {
                setState(() {
                  _isSyncEnabled = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            // Text field for server URL
            if (_isSyncEnabled) ...[
              const Text(
                'Sunucu Adresi (URL)',
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff1c3d2b),
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  hintText: 'http://localhost:9090',
                  prefixIcon: Icon(Icons.link_outlined, color: Color(0xff5a7a68)),
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Android Emulator: http://10.0.2.2:9090\nWeb/Windows: http://localhost:9090\nFiziksel Cihaz: http://<bilgisayar_ip>:9090',
                style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff5a7a68),
                  height: 1.4,
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xfff4fbf7),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: const Color(0xffdcecdd)),
                ),
                child: const Text(
                  'Çevrimdışı (Mock) modda, listeler ve hesaplar sadece uygulamanın hafızasında simüle edilir. Sunucu kurmanıza gerek kalmaz.',
                  style: TextStyle(fontSize: 12.0, color: Color(0xff5a7a68), height: 1.4),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'İptal',
            style: TextStyle(color: Color(0xff5a7a68)),
          ),
        ),
        TextButton(
          onPressed: _save,
          child: const Text(
            'Kaydet',
            style: TextStyle(color: Color(0xff5eaa82), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
