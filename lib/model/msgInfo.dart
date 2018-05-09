
import 'cardInfo.dart';


class MsgInfo {
  String mgID;              //消息ID
  String seqID;             //SeqID
  String unm;               //用户名
  String cdno;              //发送卡号
  String no;                //对话号码
  int tp;                   //类别(0:接收/1:发送)
  int st;                   //状态(-1:失败/0:待发/1:成功)
  int ns;                   //最新(0:否/1:是)
  int sd;                   //消息已推送(0:否/1:是)
  int rd;                   //阅读(0:已读/1:未读)
  String rst;               //收发时间(yyyy-mm-dd hh24:mi:ss)
  String rt;                //阅读时间(yyyy-mm-dd hh24:mi:ss)
  String t;                 //内容
  String re;                //备注
  int recode;               //CMPP返回代码
  CardInfo nomsg;

  MsgInfo({
    this.mgID,
    this.sd,
    this.seqID,
    this.st,
    this.ns,
    this.nomsg,
    this.rst,
    this.unm,
    this.no,
    this.cdno,
    this.rd,
    this.re,
    this.recode,
    this.rt,
    this.t,
    this.tp = 0
  });

  static List<MsgInfo> parseMessages(List<dynamic> data) {
    return data.map((json) => new MsgInfo.fromJson(json)).toList();
  }

  factory MsgInfo.fromJson(Map<String, dynamic> json){
    return new MsgInfo(
      mgID: json['MgID'] as String,
      seqID: json['SeqID'] as String,
      unm: json['Unm'] as String,
      cdno: json['Cdno'] as String,
      no: json['No'] as String,
      tp: json['Tp'] as int,
      t: json['T'] as String,
      rst: json['Rst'] as String,
      sd: json['Sd'] as int,
      st: json['St'] as int,
      rd: json['Rd'] as int,
      nomsg: CardInfo.fromJson(json['Nomsg']),
    );
  }
}
