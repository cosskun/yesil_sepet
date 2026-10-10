/// Item model inside a shopping list with budget, category, quantity, and status attributes.
class ShoppingItem {
  final String id;
  final String name;
  final String category;
  final String icon;
  final String? quantity;
  final double? price;
  final bool isBought;
  final bool isArchived;
  final DateTime? boughtAt;

  const ShoppingItem({
    required this.id,
    required this.name,
    this.category = 'Diğer',
    this.icon = '🛒',
    this.quantity,
    this.price,
    this.isBought = false,
    this.isArchived = false,
    this.boughtAt,
  });

  ShoppingItem copyWith({
    String? id,
    String? name,
    String? category,
    String? icon,
    String? quantity,
    double? price,
    bool? isBought,
    bool? isArchived,
    DateTime? boughtAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      isBought: isBought ?? this.isBought,
      isArchived: isArchived ?? this.isArchived,
      boughtAt: boughtAt ?? this.boughtAt,
    );
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Diğer',
      icon: json['icon']?.toString() ?? '🛒',
      quantity: json['quantity']?.toString(),
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      isBought: json['isBought'] == true,
      isArchived: json['isArchived'] == true,
      boughtAt: json['boughtAt'] != null ? DateTime.tryParse(json['boughtAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'icon': icon,
      'quantity': quantity,
      'price': price,
      'isBought': isBought,
      'isArchived': isArchived,
      'boughtAt': boughtAt?.toIso8601String(),
    };
  }
}
