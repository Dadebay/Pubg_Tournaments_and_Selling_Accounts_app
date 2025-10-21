class Tournament {
  final int id;
  final String nameTm;
  final String nameRu;
  final String descriptionTm;
  final String descriptionRu;
  final String mode;
  final String map;
  final DateTime startDate;
  final DateTime finishDate;
  final String image;
  final String price;
  final String code;
  final String lobbId;
  final String? bayrak; // 👈 new field (nullable)

  Tournament({
    required this.id,
    required this.nameTm,
    required this.nameRu,
    required this.descriptionTm,
    required this.descriptionRu,
    required this.mode,
    required this.map,
    required this.startDate,
    required this.finishDate,
    required this.image,
    required this.price,
    required this.code,
    required this.lobbId,
    this.bayrak, // 👈 add to constructor
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      nameTm: json['name_tm'] ?? '',
      nameRu: json['name_ru'] ?? '',
      descriptionTm: json['description_tm'] ?? '',
      descriptionRu: json['description_ru'] ?? '',
      mode: json['mode'] ?? '',
      map: json['map'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      finishDate: DateTime.parse(json['finish_date']),
      image: json['image'] ?? '',
      price: json['price'] ?? '',
      code: json['code'] ?? '',
      lobbId: json['lobb_id'] ?? '',
      bayrak: json['bayrak'], // 👈 parse safely (nullable)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_tm': nameTm,
      'name_ru': nameRu,
      'description_tm': descriptionTm,
      'description_ru': descriptionRu,
      'mode': mode,
      'map': map,
      'start_date': startDate.toIso8601String(),
      'finish_date': finishDate.toIso8601String(),
      'image': image,
      'price': price,
      'code': code,
      'lobb_id': lobbId,
      'bayrak': bayrak, // 👈 include in serialization
    };
  }
}

