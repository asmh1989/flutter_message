import 'package:flutter/material.dart';


class PageHelper<Data>{
  List<Data> datas = new List();
  int page = 0;
  bool inital = false;
  double _offset = 0.0;
  String snm = '';
  bool isFinish = false;

  bool handle(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      _offset = notification.metrics.extentBefore;
    }
    return false;
  }

  bool isHandle(child) {
    return child is ListView;
  }

  ScrollController createController() {
    return new ScrollController(initialScrollOffset: _offset);
  }

  void init(Function initFunction)  {
    if (!inital) {
      initFunction();
      inital = true;
    }
  }

  int itemCount() {
    return datas.length;
  }

  void addData(List<Data> datas, {clear = false}) {
    if (clear) {
      this.datas.clear();
      this.page = 0;
    }
    this.datas.addAll(datas);
    this.page++;

    isFinish = datas.isEmpty;
  }

  void clear(){
    inital = false;
    _offset = 0.0;
    snm='';
    this.datas.clear();
    page = 0;
  }
}
