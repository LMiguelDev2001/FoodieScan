//Clase que guarda el inventario.

class ModelFridge {
  final int? id;
  final int productId;
  final DateTime expirationDate;
  final int quantity;

  //los ponemos con '?' ya que de primera instancia estos parametros/datos no van a existir en la base de datos.
  final String? productImage;
  final String? productName;
  final int? productCategoryId;

  ModelFridge({
    this.id,
    required this.expirationDate,
    required this.productId,
    required this.quantity,
    this.productImage,
    this.productName,
    this.productCategoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'expirationDate': expirationDate.toIso8601String(), //toString no fuciona.
      'quantity': quantity,
    };
  }

  factory ModelFridge.fromMap(Map<String, dynamic> map) {
    return ModelFridge(
      id: map['id'],
      productId: map['productId'],
      expirationDate: DateTime.parse(map['expirationDate']),
      quantity: map['quantity'],
      productImage: map['productImage'],
      productName: map['productName'],
      productCategoryId: map['productCategoryId'],
    );
  }
}
