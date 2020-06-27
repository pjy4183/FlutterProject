class WeatherModel {
  final temp;
  final pressure;
  final humidity;
  final temp_max;
  final temp_min;
  final lon;
  final lat;

  WeatherModel(this.temp, this.pressure, this.humidity, this.temp_max, this.temp_min, this.lat, this.lon);

  factory WeatherModel.fromJason(Map<String, dynamic> json,Map<String, dynamic> json2) {
    return WeatherModel(
      json['temp'],
      json['pressure'],
      json['humidity'],
      json['temp_max'],
      json['temp_min'],
      json2['lon'],
      json2['lat']
    );
  }

}