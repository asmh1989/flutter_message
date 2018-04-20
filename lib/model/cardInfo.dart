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
//  String content;
  Map<String, dynamic> coord;

  CardInfo({
    this.no,
    this.sid,
    this.nnm,
    this.addr,
    this.opnm,
    this.insdt,
    this.unm,
    this.re,
    this.coord
  });


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


}