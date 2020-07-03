class WeatherModel {
  final name;
  final country;
  final description;
  final temp;
  final feels_like;
  final humidity;
  final temp_max;
  final temp_min;
  final lat;
  final lon;
  final wind;
  final icon;
  final forecast;
  
  // final icon;

  WeatherModel(this.name, this.country,  this.description, this.temp, this.feels_like, this.humidity, this.temp_max, this.temp_min, this.lon,this.lat, this.wind, this.icon, this.forecast);

  factory WeatherModel.fromJason(Map<String, dynamic> json,Map<String, dynamic> json2, String name, String country, String description, double wind, String icon, double forecast) {
    return WeatherModel(
      name,
      country,
      description,
      json['temp'],
      json['feels_like'],
      json['humidity'],
      json['temp_max'],
      json['temp_min'],
      json2['lon'],
      json2['lat'],
      wind,
      icon,
      forecast
    );
  }

}