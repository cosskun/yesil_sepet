/// Represents a member attached to a shared shopping list.
class ListMember {
  final String id;
  final String name;
  final bool isOwner;

  const ListMember({
    required this.id,
    required this.name,
    this.isOwner = false,
  });

  factory ListMember.fromJson(Map<String, dynamic> json) {
    return ListMember(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Üye',
      isOwner: json['isOwner'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isOwner': isOwner,
    };
  }
}
