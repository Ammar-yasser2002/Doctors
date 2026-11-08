import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Web in-memory storage fallback
  User? _webUser;
  final List<Appointment> _webAppointments = [];
  final List<Map<String, String>> _webCards = [];

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    try {
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      debugPrint('Database initialization error: $e');
      return null;
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'doctors_app.db');
    return await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // User Table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT,
        phone TEXT,
        email TEXT,
        password TEXT,
        gender TEXT,
        role TEXT,
        hospitalId TEXT,
        isProfileComplete INTEGER DEFAULT 1
      )
    ''');

    // Appointments Table
    await db.execute('''
      CREATE TABLE appointments (
        id TEXT PRIMARY KEY,
        userId TEXT,
        bookingId TEXT,
        businessName TEXT,
        doctorName TEXT,
        specialty TEXT,
        date TEXT,
        time TEXT,
        status TEXT,
        imageUrl TEXT,
        price REAL,
        isHistory INTEGER,
        appointmentType TEXT
      )
    ''');

    // Payment Cards Table
    await db.execute('''
      CREATE TABLE payment_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        number TEXT,
        expiry TEXT,
        holder TEXT,
        color TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE appointments ADD COLUMN userId TEXT');
      await db.execute(
        'ALTER TABLE users ADD COLUMN role TEXT DEFAULT "patient"',
      );
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE users ADD COLUMN email TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE users ADD COLUMN hospitalId TEXT');
    }
    if (oldVersion < 5) {
      await db.execute(
        'ALTER TABLE users ADD COLUMN isProfileComplete INTEGER DEFAULT 1',
      );
    }
  }

  // --- User Operations ---
  Future<void> saveUser(User user) async {
    if (kIsWeb) {
      _webUser = user;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('web_user', jsonEncode(user.toMap()));
      } catch (_) {}
      return;
    }

    try {
      final db = await database;
      if (db == null) return;
      await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('saveUser error: $e');
    }
  }

  Future<User?> getUser() async {
    if (kIsWeb) {
      if (_webUser != null) {
        if (_webUser!.name.contains('تجريبي') ||
            _webUser!.email == 'doctor@gmail.com' ||
            _webUser!.id.startsWith('google_fallback')) {
          _webUser = null;
        } else {
          return _webUser;
        }
      }
      try {
        final prefs = await SharedPreferences.getInstance();
        final userStr = prefs.getString('web_user');
        if (userStr != null) {
          final map = jsonDecode(userStr);
          final user = User.fromMap(Map<String, dynamic>.from(map));
          if (user.name.contains('تجريبي') ||
              user.email == 'doctor@gmail.com' ||
              user.id.startsWith('google_fallback')) {
            await prefs.remove('web_user');
            return null;
          }
          _webUser = user;
          return _webUser;
        }
      } catch (_) {}
      return null;
    }

    try {
      final db = await database;
      if (db == null) return null;
      final List<Map<String, dynamic>> maps = await db.query('users', limit: 1);
      if (maps.isEmpty) return null;
      return User.fromMap(maps.first);
    } catch (e) {
      debugPrint('getUser error: $e');
      return null;
    }
  }

  Future<void> clearUser() async {
    if (kIsWeb) {
      _webUser = null;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('web_user');
      } catch (_) {}
      return;
    }

    try {
      final db = await database;
      if (db == null) return;
      await db.delete('users');
    } catch (e) {
      debugPrint('clearUser error: $e');
    }
  }

  // --- Appointment Operations ---
  Future<void> insertAppointment(Appointment appointment) async {
    if (kIsWeb) {
      _webAppointments.removeWhere((a) => a.id == appointment.id);
      _webAppointments.add(appointment);
      return;
    }

    try {
      final db = await database;
      if (db == null) return;
      await db.insert(
        'appointments',
        appointment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('insertAppointment error: $e');
    }
  }

  Future<List<Appointment>> getAppointments() async {
    if (kIsWeb) {
      return List.from(_webAppointments);
    }

    try {
      final db = await database;
      if (db == null) return [];
      final List<Map<String, dynamic>> maps = await db.query('appointments');
      return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
    } catch (e) {
      debugPrint('getAppointments error: $e');
      return [];
    }
  }

  Future<void> deleteAppointment(String id) async {
    if (kIsWeb) {
      _webAppointments.removeWhere((a) => a.id == id);
      return;
    }

    try {
      final db = await database;
      if (db == null) return;
      await db.delete('appointments', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('deleteAppointment error: $e');
    }
  }

  // --- Payment Card Operations ---
  Future<void> insertCard(Map<String, String> card) async {
    if (kIsWeb) {
      _webCards.add(card);
      return;
    }

    try {
      final db = await database;
      if (db == null) return;
      await db.insert('payment_cards', card);
    } catch (e) {
      debugPrint('insertCard error: $e');
    }
  }

  Future<List<Map<String, String>>> getCards() async {
    if (kIsWeb) {
      return List.from(_webCards);
    }

    try {
      final db = await database;
      if (db == null) return [];
      final List<Map<String, dynamic>> maps = await db.query('payment_cards');
      return maps
          .map((m) => m.map((key, value) => MapEntry(key, value.toString())))
          .toList();
    } catch (e) {
      debugPrint('getCards error: $e');
      return [];
    }
  }

  Future<void> deleteCard(int id) async {
    if (kIsWeb) {
      if (id >= 0 && id < _webCards.length) {
        _webCards.removeAt(id);
      }
      return;
    }

    try {
      final db = await database;
      if (db == null) return;
      await db.delete('payment_cards', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('deleteCard error: $e');
    }
  }

  Future<void> clearCards() async {
    if (kIsWeb) {
      _webCards.clear();
      return;
    }

    try {
      final db = await database;
      if (db == null) return;
      await db.delete('payment_cards');
    } catch (e) {
      debugPrint('clearCards error: $e');
    }
  }
}
