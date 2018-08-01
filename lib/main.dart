import 'dart:async';

import 'package:flutter/material.dart';
import 'httpListener/http.dart';
import 'dart:convert';
import 'package:myweather/forecastweather.dart';
import 'util.dart';
import 'citylist.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new MaterialApp(
  title: "Flutter Weather",
  home: new MyApp(),
));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var home = new Scaffold(
      appBar: new AppBar(
        title: new Text("Flutter Weather"),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: new DayWeather(),
    );
    return home;
  }
}

enum More { IVR, SHARE, SETTING }

class DayWeather extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new DayWeatherState();
}

class DayWeatherState extends State<DayWeather> with NetListener {
  static const white = Colors.white;
  httpManager manager = new httpManager();

  //风力
  var _wind_sc = "0";

  //体感温度
  var _fl = "0";

  //温度
  var _tmp = "0";

  //城市
  var _location = "伦敦";

  //城市的上级城市
  var _parent_city = "法国";

  //当前天气描述
  var _cond_txt = "小辛运";

  //默认加载区域 此处我们没有定位
  var defaultCity = "浦东新区";

//  选择更多选项
  var _selection;

//  未来三天趋势预报
  List<ForeCastWeather> _data = new List();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();//todo 这个功能可能会删除

  @override
  void initState() {
    super.initState();
    _initData();
    _onCreate(defaultCity);
  }

  _initData() async {  //todo 这个功能可能会删除
/*  final SharedPreferences prefs = await _prefs;
    final int counter = (prefs.getInt('counter') ?? 0);
    print("-------------------------------");
    print("counter$counter");*/
  }

  /**
   * 获取三天的预报 and 天气实况
   */
  Future<Null> _onCreate(String cityName) async {
    await manager.getForecast(this, cityName);
    await manager.getNewWeather(this, cityName);
  }

  @override
  Widget build(BuildContext context) {
    /**
     * 当前天气widget
     */
    var currentWeather = new Container(
      margin: const EdgeInsets.only(top: 30.0, left: 30.0),
      child: new Column(
        //子项主轴左对齐
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(
            "$_tmp℃",
            style: const TextStyle(
              fontWeight: FontWeight.w200,
              fontSize: 60.0,
              color: white,
            ),
          ),
          new Text(
            "$_parent_city $_location",
            style: const TextStyle(
              color: white,
            ),
          ),
          new Text(
            "$_cond_txt",
            style: const TextStyle(
              color: white,
            ),
          ),
        ],
      ),
    );

    /**
     *
     * 当前实况天气
     */
    var futureWeather = new Container(
      margin: const EdgeInsets.only(top: 140.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Text(
            "体感温度 $_fl",
            style: const TextStyle(color: white),
          ),
          new Text(
            "风力 $_wind_sc级",
            style: const TextStyle(color: white),
            maxLines: 1,
          ),
        ],
      ),
    );
    if (_data.length == 0) {
      _data.add(new ForeCastWeather("今天", "多云", "30", "20"));
      _data.add(new ForeCastWeather("明天", "多云", "30", "20"));
      _data.add(new ForeCastWeather("后天", "多云", "30", "20"));
    }
    ForeCastWeather data0 = _data[0];
    ForeCastWeather data1 = _data[1];
    ForeCastWeather data2 = _data[2];

    /**
     * 三天趋势预报
     */
    var futureTriduum = new Container(
      margin: const EdgeInsets.only(top: 10.0),
      child: new Card(
        color: Colors.blue[200],
        child: new Column(
          children: <Widget>[
            forecastWeather(
              data0.date,
              data0.cond,
              data0.max,
              data0.min,
            ),
            forecastWeather(
              data1.date,
              data1.cond,
              data1.max,
              data1.min,
            ),
            forecastWeather(
              data2.date,
              data2.cond,
              data2.max,
              data2.min,
            ),
            new Container(
              padding: const EdgeInsets.all(15.0),
              child: new Text(
                "三天趋势预报",
                style: const TextStyle(color: white),
              ),
            ),
          ],
        ),
      ),
    );

    /**
     * 底部的导航栏  他不包含在ListView中 他应该是固定在底部的
     */
    var appBar = new Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          //iconButton有默认的padding值8.0 所以咱就不用给了
          new IconButton(
            onPressed: add,
            icon: new Icon(Icons.add),
            color: white,
          ),
          new PopupMenuButton<More>(
            //创建一个弹出menu的按钮 如果不设置icon 将使用一个默认的icon
            icon: const Icon(
              Icons.more_vert,
              color: white,
            ),
            onSelected: (More result) {
              selectedMenu(result);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<More>>[
              const PopupMenuItem<More>(
                value: More.IVR,
                child: const Text('语音播报'),
              ),
              const PopupMenuItem<More>(
                value: More.SHARE,
                child: const Text('分享天气'),
              ),
              const PopupMenuItem<More>(
                value: More.SETTING,
                child: const Text('设置'),
              ),
            ],
          ),
        ],
      ),
    );

    //整体的容器
    var content = new Container(
      width: 900.0,
      color: Colors.blue[300],
      child: new Column(
        children: <Widget>[
          new Expanded(
            child: new ListView(
              children: <Widget>[
                currentWeather,
                futureWeather,
                futureTriduum,
              ],
            ),
          ),
          appBar,
        ],
      ),
    );
    return content;
  }

  /**
   * 暂定为添加更多城市的功能
   */
  add() async {
    //拿到返回的城市
    final cityName = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new CityList()),
    );
    /**
     * 要判断防止没有选择城市这里为null
     */
    if (cityName != null) {
      //根据新的城市名 从网络从新拉取天气数据
      _onCreate(cityName);
    }
  }

  /**
   * 网络请求出错
   */
  @override
  void onError(error) {
    Scaffold
        .of(context)
        .showSnackBar(new SnackBar(content: new Text("${error.toString}")));
  }

  /**
   * 请求实况天气成功
   *
   */
  @override
  void onNewWeatherResponse(String body) {
    print("请求实况天气成功:" + body.toString());
    //此处我真是日了狗了 没有android那种插件 使用库感觉太麻烦了  就使用了内连序列化JSON
    Map<String, dynamic> user = JSON.decode(body);
    List HeWeather6 = user["HeWeather6"];
    Map<String, dynamic> parent = HeWeather6[0];
    Map<String, dynamic> newWeather = parent["now"];
    Map<String, dynamic> cid = parent["basic"];
    //城市
    _location = cid["location"];
//    城市的上级城市
    _parent_city = cid["parent_city"];
//    实况天气描述
    _cond_txt = newWeather["cond_txt"];
//    获取风力
    _wind_sc = newWeather["wind_sc"];
    //获取体感温度
    _fl = newWeather["fl"];
//    温度
    _tmp = newWeather["tmp"];
    setState(() {});
  }

  /// 请求未来三天预报成功
  @override
  void onForecastResponse(String body) {
    print("请求未来三天预报成功:" + body.toString());
    Map<String, dynamic> user = JSON.decode(body);
    List HeWeather6 = user["HeWeather6"];
    Map<String, dynamic> parent = HeWeather6[0];
    List daily_forecast = parent["daily_forecast"];
    _data.clear();
    for (int i = 0; i < daily_forecast.length; i++) {
      Map<String, dynamic> forecast = daily_forecast[i];
      //预报时间
      var date = "";
      if (i == 0) {
        date = "今天";
      } else if (i == 1) {
        date = "明天";
      } else {
        date = Util.getWeekDay();
      }
      //天气描述
      var cond_txt_d = forecast["cond_txt_d"];
      //最高温度
      var tmp_max = forecast["tmp_max"];
      //最低温度
      String tmp_min = forecast["tmp_min"];
      ForeCastWeather weather =
      new ForeCastWeather(date, cond_txt_d, tmp_max, tmp_min);
      _data.add(weather);
    }
    setState(() {});
  }

  ///将未来三天的同样的item抽取一下 不然代码太多
  Widget forecastWeather(String date, String cond, String max, String min) {
    var forecastWeather = new Container(
      padding: const EdgeInsets.all(15.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Text(
            "$date·$cond",
            style: const TextStyle(color: white),
          ),
          new Row(
            children: <Widget>[
              new Icon(
                Icons.cloud,
                color: white,
              ),
              new Container(
                  margin: const EdgeInsets.only(
                    left: 10.0,
                  ),
                  child: new Text(
                    "$max/$min℃",
                    style: const TextStyle(color: white),
                  )),
            ],
          )
        ],
      ),
    );
    return forecastWeather;
  }

  /**
   * more的菜单选项
   */
  void selectedMenu(More result) {
    switch (result) {
      case More.IVR:
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("$result:都是九年义务教育为何你这么优秀")));
        break;
      case More.SHARE:
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("$result:都是九年义务教育为何你这么优秀")));
        break;
      case More.SETTING:
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("$result:都是九年义务教育为何你这么优秀")));
        break;
    }
  }
}
