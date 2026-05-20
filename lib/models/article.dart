class Article {
  final int id;
  final String title;
  final String url;
  final String imageUrl;
  final String price;
  final String summary;
  final String publishedAt;
  final String updatedAt;
  final String category;
  final String brand;
  final int stock;
  final double discountPercentage;
  final double rating;
  final List<String> images;

  Article({
    required this.id,
    required this.title,
    required this.url,
    required this.imageUrl,
    required this.price,
    required this.summary,
    required this.publishedAt,
    required this.updatedAt,
    required this.category,
    required this.brand,
    required this.stock,
    required this.discountPercentage,
    required this.rating,
    required this.images,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    final imageList = (json['images'] as List<dynamic>?)
            ?.map((value) => value.toString())
            .toList() ??
        <String>[];
    final thumbnail = json['thumbnail']?.toString() ?? '';
    final primaryImage = imageList.isNotEmpty ? imageList.first : thumbnail;

    return Article(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      imageUrl: primaryImage,
      price: json['price']?.toString() ?? '0',
      summary: json['description'] ?? '',
      publishedAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      stock: json['stock'] ?? 0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      images: imageList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'images': images.isNotEmpty ? images : [imageUrl],
      'price': price,
      'description': summary,
      'createdAt': publishedAt,
      'updatedAt': updatedAt,
      'category': category,
      'brand': brand,
      'stock': stock,
      'discountPercentage': discountPercentage,
      'rating': rating,
    };
  }

  double get priceValue {
    return double.tryParse(price.replaceAll(RegExp(r'[^0-9\.]'), '')) ?? 0.0;
  }

  String get formattedPrice {
    return '\$${priceValue.toStringAsFixed(2)}';
  }

  String get formattedDate {
    try {
      if (publishedAt.isEmpty) {
        return '';
      }
      final date = DateTime.parse(publishedAt);
      const months = [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${date.day} ${months[date.month]} ${date.year}';
    } catch (_) {
      return publishedAt;
    }
  }

  String get formattedDiscount => '${discountPercentage.toStringAsFixed(0)}%';
}

class ArticleResponse {
  final int total;
  final int skip;
  final int limit;
  final List<Article> results;

  ArticleResponse({
    required this.total,
    required this.skip,
    required this.limit,
    required this.results,
  });

  factory ArticleResponse.fromJson(Map<String, dynamic> json) {
    // Konversi list JSON ke list Article menggunakan map()
    // DummyJSON menggunakan 'products' bukan 'results'
    final List<dynamic> productsJson = json['products'] ?? [];
    final List<Article> products = productsJson
        .map((item) => Article.fromJson(item as Map<String, dynamic>))
        .toList();

    return ArticleResponse(
      total: json['total'] ?? 0,
      skip: json['skip'] ?? 0,
      limit: json['limit'] ?? 10,
      results: products,
    );
  }
}
