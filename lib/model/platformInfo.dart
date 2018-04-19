import 'dart:convert';

class PlatformInfo{
   int lno;
   String cdno;
   String cdnm;
   String name;
   String cdurl;
   int ct;
   int ut;
   int eb;
   int exp;
   String cdtoken;
   String cdadd;

   PlatformInfo({
    this.lno,
    this.cdno,
    this.cdnm,
    this.cdadd,
    this.name,
    this.cdtoken,
    this.cdurl,
    this.ct,
    this.eb = 1,
    this.exp,
    this.ut
  });

  factory PlatformInfo.fromJson(Map<String, dynamic> json) {
    return new PlatformInfo(
      lno: json['Lno'] as int,
      cdno: json['Cdno'] as String,
      cdnm: json['Cdnm'] as String,
      name: json['Name'] as String,
      cdurl: json['Cdurl'] as String,
      ct: json['Ct'] as int,
      ut: json['Ut'] as int,
      eb: json['Eb'] as int,
      exp: json['Exp'] as int,
      cdtoken: json['Cdtoken'] as String,
      cdadd: json['Cdadd'] as String
    );
  }

  @override
  String toString() {
    Map<String, dynamic> data =  {
      'Lno': lno,
      'Cdno': cdno,
      'Cdnm': cdnm,
      'Name': name,
      'Cdurl': cdurl,
      'Eb': eb,
      'Exp': exp,
    };

    return json.encode(data);
  }
}