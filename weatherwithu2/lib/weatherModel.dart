class WeatherModel {
  final name;
  final country;
  final description;
  final temp;
  final pressure;
  final humidity;
  final temp_max;
  final temp_min;
  final lon;
  final lat;
  // final icon;

  WeatherModel(this.name, this.country,  this.description, this.temp, this.pressure, this.humidity, this.temp_max, this.temp_min, this.lat, this.lon);

  factory WeatherModel.fromJason(Map<String, dynamic> json,Map<String, dynamic> json2, String name, String country, String description) {
    return WeatherModel(
      name,
      country,
      description,
      json['temp'],
      json['pressure'],
      json['humidity'],
      json['temp_max'],
      json['temp_min'],
      json2['lon'],
      json2['lat'],
      // json3['icon']
    );
  }

}