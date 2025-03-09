import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:restaurant_app/models/restaurant.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal() {
    _instance = this;
  }

  factory DatabaseHelper() => _instance ?? DatabaseHelper._internal();

  static const String _tableName = 'favorites';

  Future<Database> _initializeDb() async {
    var path = await getDatabasesPath();
    var db = openDatabase(
      join(path, 'restaurant_db.db'),
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE $_tableName (
          id TEXT PRIMARY KEY,
          name TEXT,
          description TEXT,
          pictureId TEXT,
          city TEXT,
          rating REAL
        )''');
      },
      version: 1,
    );
    return db;
  }

  Future<Database> get database async {
    _database ??= await _initializeDb();
    return _database!;
  }

  Future<void> insertFavorite(Restaurant restaurant) async {
    final db = await database;
    await db.insert(
      _tableName,
      {
        'id': restaurant.id,
        'name': restaurant.name,
        'description': restaurant.description,
        'pictureId': restaurant.pictureId,
        'city': restaurant.city,
        'rating': restaurant.rating,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Restaurant>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    return List.generate(maps.length, (i) {
      return Restaurant(
        id: maps[i]['id'],
        name: maps[i]['name'],
        description: maps[i]['description'],
        pictureId: maps[i]['pictureId'],
        city: maps[i]['city'],
        rating: maps[i]['rating'],
      );
    });
  }

  Future<bool> isFavorite(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }

  Future<void> removeFavorite(String id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
