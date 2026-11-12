import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? database;

  Future<Database> getDataBase() async {
    if (database != null) {
      return database!;
    }

    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'student.db');

    // open the database
    Database database2 = await openDatabase(
      path,
      version: 1,

      onCreate: (Database db, int version) async {
        // When creating the db, create the table
        await db.execute(
          'CREATE TABLE students (id INTEGER PRIMARY KEY, name TEXT, age INTEGER, course TEXT)',
        );
        await db.execute(
          'CREATE TABLE Book (id INTEGER PRIMARY KEY, book_name TEXT, value INTEGER, num REAL)',
        );
      },
    );


    return database2;
  }



  Future<int> insertStudent({
    required String name,
    required int age,
    required String course,
  }) async {
    final db = await getDataBase();
    int result = await db.insert('students', {
      'name':name,
      'age': age,
      'course': course,
    });

    print("Result >> $result");
    return result;
  }


   Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await getDataBase() ;
    // print("db Type>> ${db.runtimeType}") ;
    // print("db >> ${db}") ;
    return db.query('students') ;
   }
}
