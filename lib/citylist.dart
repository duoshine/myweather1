import 'dart:async';

import 'package:flutter/material.dart';

/**
 * cityName list
 */
class CityList extends StatefulWidget {
  @override
  State<StatefulWidget> createState()=>new CityListState();
}

class CityListState extends State<CityList> {
  List<Widget> cityList = new List();

  @override
  Widget build(BuildContext context) {
    /**
     * city list使用listView来显示
     */
    var body;
    if (cityList.length == 0) {
      //默认显示一个进度条 2秒后切换为listView
      body = new CircularProgressIndicator(
        backgroundColor: Colors.cyan,
      );
      new Timer(const Duration(milliseconds: 500), () {
        cityList.add(getListTile("浦东新区",));
        cityList.add(getListTile("徐汇区"));
        cityList.add(getListTile("闵行区"));
        cityList.add(getListTile("宝山区"));
        setState(() {});
      });
    } else {
      body = new ListView(
        children: cityList,
      );
    }
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.lightBlue[300],
        title: new Text("selector city"),
      ),
      body: new Center(
        child: body,//body可能是网络加载不出来的加载界面也可能是加载出来的数据 实际开发中 我们应该这样做
      ),
    );
  }

  /**
   * 根据cityName生成listTile列表
   */
  Widget getListTile(String title) {
    return new Container(
      padding: const EdgeInsets.all(5.0),
      child: new ListTile(
        onTap: () {
          onClick(title);
        },
        leading: new Icon(Icons.location_city, color: Colors.cyan),
        title: new Text(
          title,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  /**
   * 点击城市后携带城市名返回
   */
  onClick(String title) {
    Navigator.pop(context, title);
  }
}
