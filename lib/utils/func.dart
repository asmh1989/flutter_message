
class Func {
  static bool  validatePhone(String value) {
    final RegExp phoneExp = new RegExp(r'^((1[3-8][0-9])+\d{8})$');
    return phoneExp.hasMatch(value);
  }
}