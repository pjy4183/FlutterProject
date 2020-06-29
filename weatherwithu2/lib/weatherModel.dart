class WeatherModel {
  final name;
  final country;
  final temp;
  final pressure;
  final humidity;
  final temp_max;
  final temp_min;
  final lon;
  final lat;

  WeatherModel(this.name, this.country, this.temp, this.pressure, this.humidity, this.temp_max, this.temp_min, this.lat, this.lon);

  factory WeatherModel.fromJason(Map<String, dynamic> json,Map<String, dynamic> json2, String name, String country) {
    return WeatherModel(
      name,
      country,
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