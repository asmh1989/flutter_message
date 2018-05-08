import 'dart:convert';

class CardInfo{
  String no;
  int sid;
  String cdno;
  String nnm;
  String addr;
  String opnm;
  int insdt;
  String unm;
  String re;
  String type;
//  String content;
  Map<String, dynamic> coord;

  CardInfo({
    this.no='',
    this.sid,
    this.nnm='',
    this.addr='',
    this.cdno,
    this.opnm='',
    this.insdt,
    this.unm,
    this.re='',
    this.coord,
    this.type = '1'
  });

  static List<CardInfo> parseCards(List<dynamic> data) {
    return data.map((json) => new CardInfo.fromJson(json)).toList();
  }

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    return new CardInfo(
      no: json['No'] as String,
      sid: json['Sid'] as int,
      nnm: json['Nnm'] as String,
      addr: json['Addr'] as String,
      opnm: json['Opnm'] as String,
      insdt: json['Insdt'] as int,
      unm: json['Unm'] as String,
      re: json['Re'] as String,
      coord: json['Coord'] as Map<String, dynamic>
    );
  }

  @override
  String toString() {
    Map<String, dynamic> data = {
      'No': this.no,
      'Nnm': this.nnm,
      'Addr': this.addr,
      'Opnm': this.opnm,
      'Insdt': this.insdt,
      'Re': this.re,
      'Type': this.type,
      'Coord': this.coord,
    };

    return json.encode(data);
  }


}