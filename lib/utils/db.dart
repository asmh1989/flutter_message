import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class KeyValueTable {
  static const String name = 'KEYVALUE';
  static const String id = 'ID';
  static const String key = 'KEY';
  static const String value = 'VALUE';
}

class Value {
  int id;

  Value(this.id);

  Value.fromMap(Map map){
    id = map[KeyValueTable.id];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (id != null) {
      map[KeyValueTable.id] = id;
    }

    return map;
  }

}

class KeyValue extends Value {
  String key;
  String value;

  @override
  Map<String, dynamic> toMap() {

    Map<String, dynamic> map = super.toMap();

    map.addAll({KeyValueTable.key: key, KeyValueTable.value: value});

    return map;
  }

  KeyValue({int id, String key, String value}): this.key=key, this.value = value, super(id);

  KeyValue.fromMap(Map map):super.fromMap(map) {
    key = map[KeyValueTable.key];
    value = map[KeyValueTable.value];
  }

  @override
  String toString() {
    return KeyValueTable.name;
  }
}

class DB {

  static const String _db_name = 'sms.db';

  static Database _db;
  static DB _instance;

  static DB get instance => _instance;

  static Future<Null> getDB() async {
    if(_db == null){
      String path = await _initDeleteDb(_db_name);

      _db = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {

            /// keyValue table
            await db.execute('''
create table ${KeyValueTable.name} ( 
  ${KeyValueTable.id} integer primary key autoincrement, 
  ${KeyValueTable.key} text not null,
  ${KeyValueTable.value} text not null)
''');


          });

      _instance = new DB();
    }
  }

  static Future<String> _initDeleteDb(String dbName) async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    var path = join(documentsDirectory.path, dbName);

    print(documentsDirectory);

    // make sure the folder exists
    if (await new Directory(dirname(path)).exists()) {
      await deleteDatabase(path);
    } else {
      try {
        await new Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        if (!await new Directory(dirname(path)).exists()) {
          print(e);
        }
      }
    }
    return path;
  }


  Future<T> insert<T extends Value>(T data) async {
    data.id = await _db.insert(T.toString(), data.toMap());
    return data;
  }

  Future<Null> insertOrUpdate<T extends Value>(T data, {String where, List whereArgs}) async {
    Map d = await getData<T>(where: where, whereArgs: whereArgs);
    if(d == null){
      await insert<T>(data);
    } else {
      data.id= d['ID'];
      await update<T>(data);
    }

  }

  Future<Map<String,dynamic>> getData<T extends Value>({List<String> columns, String where, List whereArgs}) async {
    List<Map<String,dynamic>> maps = await _db.query(T.toString(),
        columns: columns,
        where: where,
        whereArgs: whereArgs);
    if (maps.length > 0) {
      return  maps.first;
    }
    return null;
  }

  Future<List<Map<String,dynamic>>> getValues<T extends Value>({String where, List whereArgs, List<String> columns}) async {
    List<Map<String,dynamic>> maps = await _db.query(T.toString(),
        columns: columns,
        where: where,
        whereArgs: whereArgs
    );
    return maps;
  }


  Future<int> delete<T extends Value>({String where, List whereArgs}) async {
    return await _db.delete(T.toString(), where: where, whereArgs: whereArgs);
  }


  Future<int> update<T extends Value>(T data, {String where, List whereArg}) async {
    return await _db.update(T.toString(), data.toMap(),
        where: where?? "ID = ?", whereArgs: whereArg?? [data.id]);
  }

  Future close() async => _db.close();
}