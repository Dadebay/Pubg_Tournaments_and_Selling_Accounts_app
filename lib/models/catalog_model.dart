import 'package:get/get.dart';

import '../views/constants/constants.dart';

/// Models of the games, programs and gift cards (`/games/`, `/programs/`, `/gifts/`)
/// and of the orders and codes bought there. Read leniently: numbers may arrive as
/// strings, images may be null.

String _lang(Map json, String base) {
  final ru = Get.locale?.languageCode == 'ru';
  final value = json['${base}_${ru ? 'ru' : 'tm'}'] ?? json['${base}_${ru ? 'tm' : 'ru'}'] ?? json[base];
  return '${value ?? ''}'.trim();
}

/// A full url from what the server sends (absolute, or a path on our server); empty for none.
String catalogImage(dynamic value) {
  final path = '${value ?? ''}'.trim();
  if (path.isEmpty || path == 'null') {
    return '';
  }
  return path.startsWith('http') ? path : '$serverURL${path.startsWith('/') ? '' : '/'}$path';
}

double _number(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

int _int(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;

/// "kind" of a catalog entry: `game`, `program` or `gift`.
class CatalogBrand {
  const CatalogBrand({required this.id, required this.kind, required this.name, required this.description, required this.image, required this.productsCount, this.products = const []});

  final int id;
  final String kind;
  final String name;
  final String description;
  final String image;
  final int productsCount;
  final List<CatalogProduct> products;

  factory CatalogBrand.fromJson(Map json, {String? kind}) {
    final image = catalogImage(json['image']);
    final list = json['products'];
    return CatalogBrand(
      id: _int(json['id']),
      kind: '${json['kind'] ?? kind ?? 'game'}',
      name: _lang(json, 'name'),
      description: _lang(json, 'description'),
      image: image,
      productsCount: _int(json['products_count']),
      products: list is List ? [for (final item in list.whereType<Map>()) CatalogProduct.fromJson(item, fallbackImage: image)] : const [],
    );
  }
}

class CatalogProduct {
  const CatalogProduct({required this.id, required this.name, required this.description, required this.image, required this.price, required this.asking, required this.inStock});

  final int id;
  final String name;
  final String description;

  /// The product's picture, or the game's when it has none.
  final String image;
  final double price;

  /// The question for the buyer (games and programs): its answer goes with the order.
  final String asking;

  /// Unsold codes left (gift cards); null for games and programs.
  final int? inStock;

  bool get soldOut => inStock != null && inStock! <= 0;

  factory CatalogProduct.fromJson(Map json, {String fallbackImage = ''}) {
    final image = catalogImage(json['image']);
    return CatalogProduct(
      id: _int(json['id']),
      name: _lang(json, 'name'),
      description: _lang(json, 'description'),
      image: image.isEmpty ? fallbackImage : image,
      price: _number(json['price']),
      asking: '${json['asking'] ?? ''}'.trim(),
      inStock: json['in_stock'] == null ? null : _int(json['in_stock']),
    );
  }
}

class GameOrderItem {
  const GameOrderItem({required this.name, required this.image, required this.count, required this.price, required this.asking, required this.answer});

  final String name;
  final String image;
  final int count;
  final double price;
  final String asking;
  final String answer;

  factory GameOrderItem.fromJson(Map json) => GameOrderItem(
    name: _lang(json, 'name'),
    image: catalogImage(json['image']),
    count: _int(json['count']),
    price: _number(json['price']),
    asking: '${json['asking'] ?? ''}'.trim(),
    answer: '${json['answer'] ?? ''}'.trim(),
  );
}

/// `pending` (waiting for the admin), `success` or `failed`.
class GameOrder {
  const GameOrder({required this.id, required this.status, required this.total, required this.note, required this.refunded, required this.createdAt, required this.items});

  final int id;
  final String status;
  final double total;
  final String note;
  final bool refunded;
  final DateTime? createdAt;
  final List<GameOrderItem> items;

  factory GameOrder.fromJson(Map json) {
    final items = json['items'];
    return GameOrder(
      id: _int(json['id']),
      status: '${json['status'] ?? 'pending'}'.toLowerCase(),
      total: _number(json['total']),
      note: '${json['note'] ?? ''}'.trim(),
      refunded: json['refunded'] == true,
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}')?.toLocal(),
      items: items is List ? [for (final item in items.whereType<Map>()) GameOrderItem.fromJson(item)] : const [],
    );
  }
}

class GiftCode {
  const GiftCode({required this.id, required this.code, required this.name, required this.brand, required this.image, required this.price, required this.boughtAt});

  final int id;
  final String code;
  final String name;
  final String brand;
  final String image;
  final double price;
  final DateTime? boughtAt;

  factory GiftCode.fromJson(Map json) => GiftCode(
    id: _int(json['id']),
    code: '${json['code'] ?? ''}',
    name: _lang(json, 'name'),
    brand: _lang(json, 'brand'),
    image: catalogImage(json['image']),
    price: _number(json['price']),
    boughtAt: DateTime.tryParse('${json['bought_at'] ?? ''}')?.toLocal(),
  );
}
