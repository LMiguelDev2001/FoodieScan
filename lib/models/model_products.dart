//Clase que tiene registrados los productos.

class ModelProducts {
  final int? id;
  final int? categoryId;
  final String? image;
  final String code;
  final String name;

  ModelProducts({
    this.id,
    this.categoryId,
    this.image,
    required this.name,
    required this.code,
  });

  //tradcutor para sqlite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'categoryId': categoryId, //foreign key
      'image': image,
    };
  }

  factory ModelProducts.fromMap(Map<String, dynamic> map) {
    return ModelProducts(
      id: map['id'],
      code: map['code'],
      name: map['name'],
      categoryId: map['categoryId'],
      image: map['image'],
    );
  }
}
