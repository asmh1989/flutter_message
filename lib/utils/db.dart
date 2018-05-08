import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


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

class KeyValueTable {
  static const String name = 'KeyValue';
  static const String id = 'ID';
  static const String key = 'KEY';
  static const String value = 'VALUE';
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

class CommandValueTable {
  static const String name = 'CommandValue';
  static const String id = 'ID';
  static const String title = 'TITLE';
  static const String content = 'CONTENT';
}

class CommandValue extends Value {
  String title;
  String content;

  @override
  Map<String, dynamic> toMap() {

    Map<String, dynamic> map = super.toMap();

    map.addAll({CommandValueTable.title: title, CommandValueTable.content: content});

    return map;
  }

  CommandValue({int id, String title, String content}): this.title=title, this.content = content, super(id);

  CommandValue.fromMap(Map map):super.fromMap(map) {
    title = map[CommandValueTable.title];
    content = map[CommandValueTable.content];
  }

  @override
  String toString() {
    return CommandValueTable.name;
  }

}

class CardValueTable {
  static const String name = 'CardValue';
  static const String id = 'ID';
  static const String no = 'NO';
  static const String cdno = 'CDNO';
}

class CardValue extends Value {
  String no;
  String cdno;

  @override
  Map<String, dynamic> toMap() {

    Map<String, dynamic> map = super.toMap();

    map.addAll({CardValueTable.no: no, CardValueTable.cdno: cdno});

    return map;
  }

  CardValue({int id, String no, String cdno}): this.no=no, this.cdno = cdno, super(id);

  CardValue.fromMap(Map map):super.fromMap(map) {
    no = map[CardValueTable.no];
    cdno = map[CardValueTable.cdno];
  }

  @override
  String toString() {
    return CardValueTable.name;
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

            /// commandValue table
            await db.execute('''
create table ${CommandValueTable.name} ( 
  ${CommandValueTable.id} integer primary key autoincrement, 
  ${CommandValueTable.title} text not null,
  ${CommandValueTable.content} text not null)
''');
            /// commandValue table
            await db.execute('''
create table ${CardValueTable.name} ( 
  ${CardValueTable.id} integer primary key autoincrement, 
  ${CardValueTable.no} text not null,
  ${CardValueTable.cdno} text not null)
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
    if (!await new Directory(dirname(path)).exists()) {
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


  Future<dynamic> insert(dynamic data) async {
    data.id = await _db.insert(data.toString(), data.toMap());
    return data;
  }

  Future<Null> insertOrUpdate(dynamic data, {String where, List whereArgs}) async {
    Value d = await queryOne(data.toString(), where: where, whereArgs: whereArgs) as Value;
    if(d == null){
      await insert(data);
    } else {
//      data.id= d.id;

      print('${d.id}, ${data.id}');
      await update(data);
    }

  }

  static Value _getTypeInstance(String name, Map<String, dynamic> map){
    if(name == KeyValueTable.name){
      return new KeyValue.fromMap(map);
    } else if(name == CommandValueTable.name){
      return new CommandValue.fromMap(map);
    } else if(name == CardValueTable.name){
      return new CardValue.fromMap(map);
    }
    return new Value.fromMap(map);
  }

  Future<dynamic> queryOne(String name, {List<String> columns, String where, List whereArgs}) async {
    List<Map<String,dynamic>> maps = await _db.query(name,
        columns: columns,
        where: where,
        whereArgs: whereArgs);
    if (maps.length > 0) {
      return  maps.map( (Map<String, dynamic> f)=> _getTypeInstance(name, f)).toList()[0];
    }
    return null;
  }

  Future<List<dynamic>> query(String name, {String where, List whereArgs, List<String> columns}) async {
    List<Map<String,dynamic>> maps = await _db.query(name,
        columns: columns,
        where: where,
        whereArgs: whereArgs
    );

    print('query $name, data=$maps');

    if(maps == null){
      return <dynamic>[];
    }

    return maps.map( (Map<String, dynamic> f){
      Value value = _getTypeInstance(name, f);
      return value;
    }).toList();
  }


  Future<int> delete(String name, {String where, List whereArgs}) async {
    return await _db.delete(name, where: where, whereArgs: whereArgs);
  }


  Future<int> update(dynamic data, {String where, List whereArg}) async {
    return await _db.update(data.toString(), data.toMap(),
        where: where?? "ID = ?", whereArgs: whereArg?? [data.id]);
  }

  Future close() async => _db.close();
}