import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/model_categories.dart';
import '../models/model_fridge.dart';
import '../models/model_products.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _database;
  DatabaseHelper._instance();
}
