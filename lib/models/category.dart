class Category {
  final String slug;
  final String name;

  Category({required this.slug, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      slug: json['slug'] ?? '',
      name: json['name'] ?? json['slug'] ?? '',
    );
  }
}
