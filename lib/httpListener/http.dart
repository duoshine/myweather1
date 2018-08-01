import 'package:http/http.dart ' as http;

/**
 * 用来处理http请求和响应
 */
class httpManager {
//  三天预报
  var forecast_url = "https://free-api.heweather.com/s6/weather/forecast?parameters";
  //实况天气
  var new_weather_url =
      "https://free-api.heweather.com/s6/weather/now?parameters";

  /**
   * 三天预报
   * cityName 城市名称 我们应该使用外部传入
   * net 监听网络请求的结果 因为他不是同步的
   */
 getForecast(NetListener net,String cityName) {
    var client = new http.Client();
    client.post(
      forecast_url,
      body: {
        "location": cityName,
        "key": "eaf572c8304f4eeb8ad209bf05da2872",
      },
    ).then((
      response,
    ) {
      net.onForecastResponse(response.body);
    }, onError: (error) {
      net.onError(error);
    }).whenComplete(
      client.close,
    );
  }

  /**
   * 获取实况天气
   */
  getNewWeather(NetListener net,String cityName)  {
    var client = new http.Client();
    client.post(
      new_weather_url,
      body: {
        "location": cityName,
        "key": "eaf572c8304f4eeb8ad209bf05da2872",
      },
    ).then((
      response,
    ) {
      net.onNewWeatherResponse(response.body);
    }, onError: (error) {
      net.onError(error);
    }).whenComplete(
      client.close,
    );
  }
}

/**
 * 用来回调成功和失败的结果
 */
abstract class NetListener {
  //实况天气
  void onNewWeatherResponse(String body);
  //三天预报
  void onForecastResponse(String body);

  void onError(error);
}
