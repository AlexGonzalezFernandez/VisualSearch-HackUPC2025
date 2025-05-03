class Price {
  final double current;
  final double? original;
  final String currency;

  Price({
    required this.current,
    this.original,
    required this.currency,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      current: (json['value']['current'] ?? 0.0).toDouble(),
      original: json['value']['original']?.toDouble(),
      currency: json['currency'] ?? 'USD',
    );
  }

  double? get discountPercentage {
    if (original != null && original! > 0) {
      return ((original! - current) / original!) * 100;
    }
    return null;
  }

  String formatPrice(double amount) {
    return currency == 'EUR' ? '${amount}€' : '$amount $currency';
  }

  String get currentFormatted => formatPrice(current);
  String? get originalFormatted =>
      original != null ? formatPrice(original!) : null;
}

class ClothingItem {
  final String name;
  final Price price;
  final String link;
  final String imageUrl;

  ClothingItem({
    required this.name,
    required this.price,
    required this.link,
    required this.imageUrl,
  });

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      name: json['name'] ?? 'No name',
      price: Price.fromJson(json['price']),
      link: json['link'] ?? '',
      imageUrl: json['image_url'] ?? 'Empty image URL',
    );
  }
}
