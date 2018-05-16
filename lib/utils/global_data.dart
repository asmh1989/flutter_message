typedef void VoidRefresh();

class Global {
  static VoidRefresh _cardRefresh;
  static VoidRefresh _msgRefresh;

  setCardRefresh(VoidRefresh r){
    _cardRefresh = r;
  }

  setMsgRefresh(VoidRefresh r){
    _msgRefresh = r;
  }

  runCardRefresh(){
    if(_cardRefresh != null) _cardRefresh();
  }

  runMsgRefresh(){
    if(_msgRefresh != null) _msgRefresh();
  }

}

