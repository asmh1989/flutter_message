class PlatformInfo{
  final int lno;
  final String cdno;
  final String cdnm;
  final String name;
  final String cdurl;
  final int ct;
  final int ut;
  final int eb;
  final int exp;
  final String cdtoken;
  final String cdadd;

  const PlatformInfo({
    this.lno,
    this.cdno,
    this.cdnm,
    this.cdadd,
    this.name,
    this.cdtoken,
    this.cdurl,
    this.ct,
    this.eb,
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
}