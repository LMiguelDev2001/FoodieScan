//Clase que tiene registrados los productos.

class ModelProducts {
  final int? id;
  final String code;
  final String name;
  final int categoryId;
  final String image;

  ModelProducts({
    this.id,
    required this.name,
    required this.code,
    required this.categoryId,
    required this.image,
  });

  //tradcutor para sqlite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'categoryId': categoryId,
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
