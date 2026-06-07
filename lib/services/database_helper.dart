import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/model_categories.dart';
import '../models/model_fridge.dart';
import '../models/model_products.dart';

class DatabaseHelper {
  //patron singleton
  //el punto de acceso es instance
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
      categoryId INTEGER,
      image TEXT,

      FOREIGN KEY (categoryId) REFERENCES categories(id)    
    )''');

    //tabla del inventario
    await db.execute('''CREATE TABLE fridge(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      productId INTEGER,
      quantity INTEGER NOT NULL,
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
      ModelCategories(name: 'lacteos', image: 'assets/1.png'),
      ModelCategories(name: 'carne, huevos y pescados', image: 'assets/2.png'),
      ModelCategories(
        name: 'tubérculos, legumbres y frutos secos',
        image: 'assets/3.png',
      ),
      ModelCategories(name: 'verduras y hortalizas', image: 'assets/4.png'),
      ModelCategories(name: 'frutas ', image: 'assets/5.png'),
      ModelCategories(name: 'pan, pasta, cereales', image: 'assets/6.png'),
      ModelCategories(name: 'aceite y mantequillas', image: 'assets/7.png'),
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

  //PRODUCTOS
  //PRODUCTS**PRODUCTS**PRODUCTS**PRODUCTS**PRODUCTS**PRODUCTS**PRODUCTS**PRODUCTS**PRODUCTS**PRODUCTS**PRODUCTS**
  //funcion para insertar los productos dentro de la tabla.
  Future<int> insertProducts(ModelProducts products) async {
    Database db = await instance.db;
    return await db.insert('products', products.toMap());
  }

  //funcion para leer los productos.
  Future<List<ModelProducts>> readProducts() async {
    Database db = await instance.db;
    final List<Map<String, dynamic>> productsMaps = await db.query(
      'products',
      orderBy: 'id DESC',
    ); //importante resaltar que no es necesario concretar el tipo de dato. Dart lo hace de forma automatica.
    //Aquí se ha hecho por fines educativos, para no liar al alumno o al profesor.
    return productsMaps
        .map((mapping) => ModelProducts.fromMap(mapping))
        .toList();
  }

  //funcion para leer producto por codigo de barras.
  //Se usa para buscar un producto y comprobar su existencia en la base de datos local.
  Future<ModelProducts?> readProductByBarcode(String code) async {
    Database db = await instance.db;
    final List<Map<String, dynamic>> barcodeProduct = await db.query(
      'products',
      where: 'code = ?',
      whereArgs: [code],
    );
    //si no encuentra el producto, no devuelve null, devuelve una lista vacia (pero no null);
    if (barcodeProduct.isEmpty) {
      return null;
    } else {
      return barcodeProduct
          .map((mapped) => ModelProducts.fromMap(mapped))
          .toList()
          .first;
    }
  }

  //funcion para actualziar la categoria de product
  Future<int> updateCategory(int categoryId, int id) async {
    Database db = await instance.db;
    return await db.rawUpdate('''
      UPDATE products

      SET categoryId = $categoryId

      WHERE id = $id;

    ''');
  }

  Future<int> deleteProduct(int id) async {
    Database db = await instance.db;

    return await db.rawDelete('''
      DELETE FROM products

      WHERE id = $id
      
    ''');
  }

  //NEVERA**NEVERA**NEVERA**NEVERA**NEVERA**NEVERA**NEVERA**NEVERA**NEVERA**NEVERA**NEVERA**NEVERA**NEVERA
  //funcion para insertar los products comprados dentro de la tabla.
  Future<int> insertGoods(ModelFridge goods) async {
    Database db = await instance.db;
    return await db.insert('fridge', goods.toMap());
  }

  //funcion pora insertar las mercancias.

  //funcion para leer la compra. Esto significa que la funcióln siguiente sirve para leer la compra
  Future<List<ModelFridge>> readGoods() async {
    Database db = await instance.db;

    final List<Map<String, dynamic>> goodsMaps = await db.rawQuery('''
      SELECT
        fridge.id,
        fridge.productId,
        fridge.quantity, 
        fridge.expirationDate, 
        products.name AS productName, 
        products.image AS productImage,
        products.categoryId AS productCategoryId
      FROM fridge

      INNER JOIN products on fridge.productId = products.id
      ORDER BY fridge.id DESC

    ''');
    return goodsMaps.map((mapping) => ModelFridge.fromMap(mapping)).toList();
  }

  //Borrar un elemento de la nevera uno a uno. Si llega a 0, se borra el producto.
  Future<void> deleteIndividualFridgeProduct(int id) async {
    Database db = await instance.db;

    await db.rawUpdate('''
      UPDATE fridge
        SET quantity = quantity - 1
        WHERE id = $id         
    ''');

    await db.rawDelete('''
      DELETE FROM fridge
      WHERE id = $id AND quantity <= 0
      ''');
  }

  //borra el producto de la nevera del tiron.
  Future<int> deleteFullFridgeProduct(int id) async {
    Database db = await instance.db;

    return await db.rawDelete('''
      DELETE FROM fridge
      WHERE productId = $id
    ''');
  }
}
