import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/model_categories.dart';
import '../models/model_fridge.dart';
import '../models/model_products.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _database;
  DatabaseHelper._instance();

  Future<Database> get db async {
    _database ??= await dbInitiate();
    return _database!; //el signo ! sirve para indicarle que el valor que retornamos nunca sera null.
  }

  Future<Database> dbInitiate() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'foodScans.db');

    return await openDatabase(path, version: 1, onCreate: _dbCreate);
  }

  Future _dbCreate(Database db, int version) async {
    //tabla de las categorias
    await db.execute('''
    CREATE TABLE categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      image TEXT NOT NULL    
    )''');

    //creamos las categorias y las insertamos..
    await addDefaultCategories(db);

    //tabla de los productos
    await db.execute('''CREATE TABLE products(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      code TEXT NOT NULL,
      name TEXT NOT NULL,
      categoryId INTEGER NOT NULL,
      image TEXT NOT NULL,

      FOREIGN KEY (categoryId) REFERENCES categories(id)    
    )''');

    //tabla del inventario
    await db.execute('''CREATE TABLE fridge(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      productId INTEGER NOT NULL,
      expirationDate TEXT NOT NULL,

      FOREIGN KEY (productId) REFERENCES products(id)   
    )''');
  }

  //CATEGORIAS
  //funcion para habilitar el poder introducir de forma manual las categorias por defecto
  Future<int> insertCategories(
    ModelCategories defaultCategories,
    Database db,
  ) async {
    return await db.insert('categories', defaultCategories.toMap());
  }

  //funcion pora insertar las categorias.
  Future<void> addDefaultCategories(Database db) async {
    List<ModelCategories> addCategories = [
      ModelCategories(name: 'leche y derivados', image: 'assets/1.png'),
      ModelCategories(name: 'carne, huevos y pescados', image: 'assets/2.png'),
      ModelCategories(
        name: 'tubérculos, legumbres y frutos secos',
        image: 'assets/3.png',
      ),
      ModelCategories(name: 'verduras y hortalizas', image: 'assets/4.png'),
      ModelCategories(name: 'frutas ', image: 'assets/5.png'),
      ModelCategories(
        name: 'pan, pasta, cereales y azúcar',
        image: 'assets/6.png',
      ),
      ModelCategories(
        name: 'grasas, aceite y mantequillas',
        image: 'assets/7.png',
      ),
      ModelCategories(name: 'otros ', image: 'assets/8.png'),
    ];

    for (ModelCategories defaultCategories in addCategories) {
      await insertCategories(defaultCategories, db);
    }
  }

  //funcion para leer categorias.
  Future<List<ModelCategories>> readCategories() async {
    Database db = await instance.db;

    final List<Map<String, dynamic>> categoriesMaps = await db.query(
      'categories',
    ); //importante resaltar que no es necesario concretar el tipo de dato. Dart lo hace de forma automatica.
    //Aquí se ha hecho por fines educativos, para no liar al alumno o al profesor.

    return categoriesMaps
        .map((mapping) => ModelCategories.fromMap(mapping))
        .toList();
  }

  //PRODUCTS**PRODUCTS**PRODUCTS**PRODUCTS**PRODUCTS**PRODUCTS**PRODUCTS**PRODUCTS**PRODUCTS**PRODUCTS**PRODUCTS**
  //funcion para insertar los productos dentro de la tabla.
  Future<int> insertProducts(ModelProducts products) async {
    Database db = await instance.db;
    return await db.insert('products', products.toMap());
  }

  //funcion pora insertar las categorias.

  //funcion para leer los productos.
  Future<List<ModelProducts>> readProducts() async {
    Database db = await instance.db;

    final List<Map<String, dynamic>> productsMaps = await db.query(
      'products',
    ); //importante resaltar que no es necesario concretar el tipo de dato. Dart lo hace de forma automatica.
    //Aquí se ha hecho por fines educativos, para no liar al alumno o al profesor.

    return productsMaps
        .map((mapping) => ModelProducts.fromMap(mapping))
        .toList();
  }

  //NEVERA**NEVERA**NEVERA**NEVERA**NEVERA**NEVERA**NEVERA**NEVERA**NEVERA**NEVERA**NEVERA**NEVERA**NEVERA**NEVERA**
  //funcion para insertar los products comprados dentro de la tabla.
  Future<int> insertGoods(ModelFridge goods) async {
    Database db = await instance.db;
    return await db.insert('fridge', goods.toMap());
  }

  //funcion pora insertar las mercancias.

  //funcion para leer la compra.
  Future<List<ModelFridge>> readGoods() async {
    Database db = await instance.db;

    final List<Map<String, dynamic>> goodsMaps = await db.query(
      'fridge',
    ); //importante resaltar que no es necesario concretar el tipo de dato. Dart lo hace de forma automatica.
    //Aquí se ha hecho por fines educativos, para no liar al alumno o al profesor.

    return goodsMaps.map((mapping) => ModelFridge.fromMap(mapping)).toList();
  }
}
