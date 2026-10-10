/// Represents an item processed by [SmartCategorizer] with extracted metadata.
class CategorizedItem {
  final String name;
  final String category;
  final String icon;
  final String? quantity;

  CategorizedItem({
    required this.name,
    required this.category,
    required this.icon,
    this.quantity,
  });
}

/// Smart categorization engine that recognizes food and household items,
/// assigns categories/emojis, extracts units/quantities, and parses multi-item sentences.
class SmartCategorizer {
  static final Map<String, Map<String, dynamic>> _dictionary = {
    // Manav
    'elma': {'cat': 'Manav', 'icon': '🍎'},
    'amasya elması': {'cat': 'Manav', 'icon': '🍎'},
    'yeşil elma': {'cat': 'Manav', 'icon': '🍏'},
    'armut': {'cat': 'Manav', 'icon': '🍐'},
    'muz': {'cat': 'Manav', 'icon': '🍌'},
    'portakal': {'cat': 'Manav', 'icon': '🍊'},
    'mandalina': {'cat': 'Manav', 'icon': '🍊'},
    'limon': {'cat': 'Manav', 'icon': '🍋'},
    'çilek': {'cat': 'Manav', 'icon': '🍓'},
    'üzüm': {'cat': 'Manav', 'icon': '🍇'},
    'karpuz': {'cat': 'Manav', 'icon': '🍉'},
    'kavun': {'cat': 'Manav', 'icon': '🍈'},
    'şeftali': {'cat': 'Manav', 'icon': '🍑'},
    'kiraz': {'cat': 'Manav', 'icon': '🍒'},
    'ananas': {'cat': 'Manav', 'icon': '🍍'},
    'kivi': {'cat': 'Manav', 'icon': '🥝'},
    'avokado': {'cat': 'Manav', 'icon': '🥑'},
    'domates': {'cat': 'Manav', 'icon': '🍅'},
    'salatalık': {'cat': 'Manav', 'icon': '🥒'},
    'patates': {'cat': 'Manav', 'icon': '🥔'},
    'soğan': {'cat': 'Manav', 'icon': '🧅'},
    'sarallık soğan': {'cat': 'Manav', 'icon': '🧅'},
    'sarımsak': {'cat': 'Manav', 'icon': '🧄'},
    'biber': {'cat': 'Manav', 'icon': '🫑'},
    'patlıcan': {'cat': 'Manav', 'icon': '🍆'},
    'havuç': {'cat': 'Manav', 'icon': '🥕'},
    'mısır': {'cat': 'Manav', 'icon': '🌽'},
    'brokoli': {'cat': 'Manav', 'icon': '🥦'},
    'marul': {'cat': 'Manav', 'icon': '🥬'},
    'yeşillik': {'cat': 'Manav', 'icon': '🥬'},
    'maydanoz': {'cat': 'Manav', 'icon': '🌿'},
    'nane': {'cat': 'Manav', 'icon': '🌿'},
    'ıspanak': {'cat': 'Manav', 'icon': '🥬'},
    'karnabahar': {'cat': 'Manav', 'icon': '🥦'},

    // Süt Ürünleri & Kahvaltılık
    'süt': {'cat': 'Süt Ürünleri', 'icon': '🥛'},
    'laktozsuz süt': {'cat': 'Süt Ürünleri', 'icon': '🥛'},
    'peynir': {'cat': 'Süt Ürünleri', 'icon': '🧀'},
    'kaşar': {'cat': 'Süt Ürünleri', 'icon': '🧀'},
    'kaşar peyniri': {'cat': 'Süt Ürünleri', 'icon': '🧀'},
    'beyaz peynir': {'cat': 'Süt Ürünleri', 'icon': '🧀'},
    'tulum peyniri': {'cat': 'Süt Ürünleri', 'icon': '🧀'},
    'süzme peynir': {'cat': 'Süt Ürünleri', 'icon': '🧀'},
    'tereyağı': {'cat': 'Süt Ürünleri', 'icon': '🧈'},
    'tereyağ': {'cat': 'Süt Ürünleri', 'icon': '🧈'},
    'margarin': {'cat': 'Süt Ürünleri', 'icon': '🧈'},
    'yoğurt': {'cat': 'Süt Ürünleri', 'icon': '🍦'},
    'süzme yoğurt': {'cat': 'Süt Ürünleri', 'icon': '🍦'},
    'ayran': {'cat': 'Süt Ürünleri', 'icon': '🥛'},
    'krema': {'cat': 'Süt Ürünleri', 'icon': '🥛'},
    'kaymak': {'cat': 'Süt Ürünleri', 'icon': '🍨'},
    'yumurta': {'cat': 'Süt Ürünleri', 'icon': '🥚'},
    'organik yumurta': {'cat': 'Süt Ürünleri', 'icon': '🥚'},
    'zeytin': {'cat': 'Süt Ürünleri', 'icon': '🫒'},
    'siyah zeytin': {'cat': 'Süt Ürünleri', 'icon': '🫒'},
    'yeşil zeytin': {'cat': 'Süt Ürünleri', 'icon': '🫒'},
    'bal': {'cat': 'Süt Ürünleri', 'icon': '🍯'},
    'reçel': {'cat': 'Süt Ürünleri', 'icon': '🫐'},
    'tahin': {'cat': 'Süt Ürünleri', 'icon': '🏺'},
    'pekmez': {'cat': 'Süt Ürünleri', 'icon': '🏺'},

    // Fırın & Pastane
    'ekmek': {'cat': 'Fırın & Pastane', 'icon': '🥖'},
    'somun ekmek': {'cat': 'Fırın & Pastane', 'icon': '🥖'},
    'tost ekmeği': {'cat': 'Fırın & Pastane', 'icon': '🍞'},
    'kepekli ekmek': {'cat': 'Fırın & Pastane', 'icon': '🍞'},
    'tam buğday ekmeği': {'cat': 'Fırın & Pastane', 'icon': '🍞'},
    'simit': {'cat': 'Fırın & Pastane', 'icon': '🥐'},
    'poğaça': {'cat': 'Fırın & Pastane', 'icon': '🥐'},
    'açma': {'cat': 'Fırın & Pastane', 'icon': '🥐'},
    'börek': {'cat': 'Fırın & Pastane', 'icon': '🥐'},
    'pide': {'cat': 'Fırın & Pastane', 'icon': '🫓'},
    'yufka': {'cat': 'Fırın & Pastane', 'icon': '🫓'},
    'lavaş': {'cat': 'Fırın & Pastane', 'icon': '🫓'},
    'pasta': {'cat': 'Fırın & Pastane', 'icon': '🍰'},
    'kek': {'cat': 'Fırın & Pastane', 'icon': '🧁'},

    // Et, Tavuk & Balık
    'kıyma': {'cat': 'Et & Balık', 'icon': '🥩'},
    'dana kıyma': {'cat': 'Et & Balık', 'icon': '🥩'},
    'kuşbaşı': {'cat': 'Et & Balık', 'icon': '🥩'},
    'et': {'cat': 'Et & Balık', 'icon': '🥩'},
    'bonfile': {'cat': 'Et & Balık', 'icon': '🥩'},
    'antrikot': {'cat': 'Et & Balık', 'icon': '🥩'},
    'köfte': {'cat': 'Et & Balık', 'icon': '🧆'},
    'tavuk': {'cat': 'Et & Balık', 'icon': '🍗'},
    'tavuk göğsü': {'cat': 'Et & Balık', 'icon': '🍗'},
    'tavuk kanat': {'cat': 'Et & Balık', 'icon': '🍗'},
    'tavuk pirzola': {'cat': 'Et & Balık', 'icon': '🍗'},
    'balık': {'cat': 'Et & Balık', 'icon': '🐟'},
    'somon': {'cat': 'Et & Balık', 'icon': '🐟'},
    'hamsi': {'cat': 'Et & Balık', 'icon': '🐟'},
    'sucuk': {'cat': 'Et & Balık', 'icon': '🥓'},
    'salam': {'cat': 'Et & Balık', 'icon': '🌭'},
    'sosis': {'cat': 'Et & Balık', 'icon': '🌭'},
    'pastırma': {'cat': 'Et & Balık', 'icon': '🥓'},

    // Temizlik & Ev Bakımı
    'deterjan': {'cat': 'Temizlik', 'icon': '🧹'},
    'çamaşır deterjanı': {'cat': 'Temizlik', 'icon': '🧹'},
    'bulaşık deterjanı': {'cat': 'Temizlik', 'icon': '🧼'},
    'yumuşatıcı': {'cat': 'Temizlik', 'icon': '🧴'},
    'çamaşır suyu': {'cat': 'Temizlik', 'icon': '🧴'},
    'tuvalet kağıdı': {'cat': 'Temizlik', 'icon': '🧻'},
    'kağıt havlu': {'cat': 'Temizlik', 'icon': '🧻'},
    'peçete': {'cat': 'Temizlik', 'icon': '🧻'},
    'sabun': {'cat': 'Temizlik', 'icon': '🧼'},
    'sıvı sabun': {'cat': 'Temizlik', 'icon': '🧼'},
    'sünger': {'cat': 'Temizlik', 'icon': '🧽'},
    'bulaşık süngeri': {'cat': 'Temizlik', 'icon': '🧽'},
    'çöp poşeti': {'cat': 'Temizlik', 'icon': '🪠'},
    'yüzey temizleyici': {'cat': 'Temizlik', 'icon': '🧹'},

    // Kişisel Bakım
    'şampuan': {'cat': 'Kişisel Bakım', 'icon': '🧴'},
    'saç kremi': {'cat': 'Kişisel Bakım', 'icon': '🧴'},
    'duş jeli': {'cat': 'Kişisel Bakım', 'icon': '🧴'},
    'diş fırçası': {'cat': 'Kişisel Bakım', 'icon': '🪥'},
    'diş macunu': {'cat': 'Kişisel Bakım', 'icon': '🪥'},
    'deodorant': {'cat': 'Kişisel Bakım', 'icon': '✨'},
    'pamuk': {'cat': 'Kişisel Bakım', 'icon': '☁️'},
    'krem': {'cat': 'Kişisel Bakım', 'icon': '💄'},

    // İçecekler
    'su': {'cat': 'İçecekler', 'icon': '🥤'},
    'maden suyu': {'cat': 'İçecekler', 'icon': '🍾'},
    'soda': {'cat': 'İçecekler', 'icon': '🍾'},
    'çay': {'cat': 'İçecekler', 'icon': '🍵'},
    'kahve': {'cat': 'İçecekler', 'icon': '☕'},
    'meyve suyu': {'cat': 'İçecekler', 'icon': '🧃'},
    'kola': {'cat': 'İçecekler', 'icon': '🥤'},
    'gazoz': {'cat': 'İçecekler', 'icon': '🥤'},

    // Temel Gıda & Bakliyat
    'pirinç': {'cat': 'Temel Gıda', 'icon': '🌾'},
    'bulgur': {'cat': 'Temel Gıda', 'icon': '🌾'},
    'makarna': {'cat': 'Temel Gıda', 'icon': '🍝'},
    'erişte': {'cat': 'Temel Gıda', 'icon': '🍝'},
    'un': {'cat': 'Temel Gıda', 'icon': '🌾'},
    'şeker': {'cat': 'Temel Gıda', 'icon': '🍬'},
    'tuz': {'cat': 'Temel Gıda', 'icon': '🧂'},
    'sıvı yağ': {'cat': 'Temel Gıda', 'icon': '🫒'},
    'zeytinyağı': {'cat': 'Temel Gıda', 'icon': '🫒'},
    'ayçiçek yağı': {'cat': 'Temel Gıda', 'icon': '🫒'},
    'salça': {'cat': 'Temel Gıda', 'icon': '🥫'},
    'domates salçası': {'cat': 'Temel Gıda', 'icon': '🥫'},
    'biber salçası': {'cat': 'Temel Gıda', 'icon': '🥫'},
    'mercimek': {'cat': 'Temel Gıda', 'icon': '🫘'},
    'kuru fasulye': {'cat': 'Temel Gıda', 'icon': '🫘'},
    'nohut': {'cat': 'Temel Gıda', 'icon': '🫘'},

    // Atıştırmalık
    'çikolata': {'cat': 'Atıştırmalık', 'icon': '🍫'},
    'bisküvi': {'cat': 'Atıştırmalık', 'icon': '🍪'},
    'gofret': {'cat': 'Atıştırmalık', 'icon': '🍫'},
    'cips': {'cat': 'Atıştırmalık', 'icon': '🍿'},
    'kuruyemiş': {'cat': 'Atıştırmalık', 'icon': '🥜'},
    'fındık': {'cat': 'Atıştırmalık', 'icon': '🥜'},
    'fıstık': {'cat': 'Atıştırmalık', 'icon': '🥜'},
    'ceviz': {'cat': 'Atıştırmalık', 'icon': '🥜'},
    'dondurma': {'cat': 'Atıştırmalık', 'icon': '🍨'},
  };

  /// Analyzes single item text input, extracts units/quantities, and assigns category + emoji.
  static CategorizedItem categorize(String rawText) {
    String text = rawText.trim();
    if (text.isEmpty) {
      return CategorizedItem(name: '', category: 'Diğer', icon: '🛒');
    }

    String? extractedQuantity;
    String cleanName = text;

    final quantityRegex = RegExp(
      r'^\s*(\d+(?:[\.,]\d+)?)\s*(kg|kilo|kilogram|g|gr|gram|l|lt|litre|adet|paket|kutu|demet|bağ|kasa)\b\s*',
      caseSensitive: false,
    );

    final match = quantityRegex.firstMatch(cleanName);
    if (match != null) {
      final val = match.group(1)!;
      final unitRaw = match.group(2)!.toLowerCase();
      String unit = unitRaw;
      if (unitRaw == 'kilo' || unitRaw == 'kilogram') unit = 'kg';
      if (unitRaw == 'litre' || unitRaw == 'lt') unit = 'L';
      if (unitRaw == 'gram') unit = 'gr';

      extractedQuantity = '$val $unit';
      cleanName = cleanName.substring(match.end).trim();
    }

    if (cleanName.isNotEmpty) {
      cleanName = cleanName[0].toUpperCase() + cleanName.substring(1);
    } else {
      cleanName = text;
    }

    final lowerClean = cleanName.toLowerCase();

    String category = 'Diğer';
    String icon = '🛒';

    for (var entry in _dictionary.entries) {
      if (lowerClean == entry.key || lowerClean.contains(entry.key)) {
        category = entry.value['cat'] as String;
        icon = entry.value['icon'] as String;
        break;
      }
    }

    return CategorizedItem(
      name: cleanName,
      category: category,
      icon: icon,
      quantity: extractedQuantity,
    );
  }

  /// Parses sentence/voice input containing multiple items into a list of categorized items.
  static List<CategorizedItem> parseMultiItemText(String text) {
    if (text.trim().isEmpty) return [];

    String sanitized = text
        .replaceAll('\n', '|')
        .replaceAll(';', '|')
        .replaceAll(',', '|')
        .replaceAll(RegExp(r'\bve\b', caseSensitive: false), '|')
        .replaceAll(RegExp(r'\bile\b', caseSensitive: false), '|');

    List<String> rawParts = sanitized.split('|');
    List<CategorizedItem> results = [];

    for (var part in rawParts) {
      final trimmed = part.trim();
      if (trimmed.isNotEmpty && trimmed.length > 1) {
        results.add(categorize(trimmed));
      }
    }

    return results;
  }
}
