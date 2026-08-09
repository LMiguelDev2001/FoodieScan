//Clase donde se guardan las categorias.

class ModelCategories {
  final int? id; //El simobolo '?' se pone pra indicar que id puede ser nulo.
  final String name;

  ModelCategories({
    //id no ncesita required porque puede ser nulo.
    this.id,
    required this.name,
  });

  //tradcutor para sqlite
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  //convertimos
  factory ModelCategories.fromMap(Map<String, dynamic> map) {
    return ModelCategories(id: map['id'], name: map['name']);
  }
}
