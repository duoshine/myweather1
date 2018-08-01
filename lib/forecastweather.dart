/**
 * 数据实体类 封装未来三天的天气情况
 */
class ForeCastWeather {
  final String date; //日期
  final String cond; //天气描述
  final String max; //最高温度
  final String min;//最低温度

  ForeCastWeather(this.date, this.cond, this.max, this.min);

  @override
  String toString() {
    return 'ForeCastWeather{date: $date, cond: $cond, max: $max, min: $min}';
  }


}
