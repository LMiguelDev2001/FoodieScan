//Clase que guarda el inventario.

class ModelFridge {
  final int? id;
  final int productId;
  final DateTime expirationDate;

  ModelFridge({this.id, required this.expirationDate, required this.productId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'expirationDate': expirationDate.toIso8601String(), //toString no fuciona.
    };
  }

  factory ModelFridge.fromMap(Map<String, dynamic> map) {
    return ModelFridge(
      id: map['id'],
      productId: map['productId'],
      expirationDate: DateTime.parse(
        map['expirationDate'],
      ), //lo volvemos a poner en formato date.
    );
  }
}
