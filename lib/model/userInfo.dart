import 'dart:convert';

class CdNos {
  int auth;
  String cdno;
  String name;

  CdNos({
    this.auth,
    this.cdno,
    this.name,
  });

  factory CdNos.fromJson(Map<String, dynamic> json){
    return new CdNos(
      auth: json['Auth'] as int,
      cdno: json['Cdno'] as String,
      name: json['Name'] as String,
    );
  }

  @override
  String toString() {
    return json.encode({
      'Auth': auth,
      'Cdno': cdno,
      'Name': name
    });
  }

  Map<String, dynamic> toMap(){
    return {
      'Auth': auth,
      'Cdno': cdno,
      'Name': name
    };
  }
}

class UserInfo {
  String unm;
  String upd;
  String upid;
  String udep;
  String ujob;
  int enable;
  int state;
  int ut;
  String warn;
  int admin;
  int all;
//  dynamic platform;

  List<CdNos> cdnos;


  UserInfo({
    this.unm,
    this.upd,
    this.upid,
    this.udep,
    this.ujob,
    this.enable = 1,
    this.admin = 2,
    this.all = 1,
    this.cdnos,
    this.state,
    this.warn,
    this.ut,
//    this.platform
  });


  factory UserInfo.fromJson(Map<String, dynamic> json) {

    dynamic platform = json['Platform'];
    if(platform == null) return new UserInfo(unm: 'platform数据有误');


    List<CdNos> c = (platform['Cdnos'] as List).map((f) => new CdNos.fromJson(f)).toList();

    return new UserInfo(
      unm: json['Unm'] as String,
      upd: json['Upd'] as String,
      udep: json['Udep'] as String,
      ujob: json['Ujob'] as String,
      upid: json['Upid'] as String,
      enable: json['Enable'] as int,
      state: json['State'] as int,
      ut: json['Ut'] as int,
      admin: json['Admin'] as int,
      all: platform['All'] as int,
      cdnos: c,
    );
  }

  @override
  String toString() {
    List<String> list = [];
    cdnos.forEach((CdNos c){
      if(c.auth == 1)
        list.add(c.cdno);
    });

    Map<String, dynamic> data = {
      'Unm': unm,
      'Upd': upd,
      'Upid': upid,
      'Udep': udep,
      'Ujob': ujob,
      'Admin': admin,
      'Enable': enable,
      'Platform': {
        'All': all,
        'Cdnos': list
      }
    };
    return json.encode(data);
  }
}