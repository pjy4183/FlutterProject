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
  final day1_temp_min;
  final day1_temp_max;
  final day1_icon;
  final day2_temp_min;
  final day2_temp_max;
  final day2_icon;
  final day3_temp_min;
  final day3_temp_max;
  final day3_icon;
  final day4_temp_min;
  final day4_temp_max;
  final day4_icon;
  final day5_temp_min;
  final day5_temp_max;
  final day5_icon;
  final day6_temp_min;
  final day6_temp_max;
  final day6_icon;
  final day7_temp_min;
  final day7_temp_max;
  final day7_icon;

  WeatherModel(this.name, this.country,  this.description, this.temp, this.feels_like, this.humidity, this.temp_max, this.temp_min, this.lon,this.lat, this.wind, this.icon,
            this.day1_temp_min, this.day1_temp_max, this.day1_icon, this.day2_temp_min, this.day2_temp_max, this.day2_icon,
            this.day3_temp_min, this.day3_temp_max, this.day3_icon, this.day4_temp_min, this.day4_temp_max, this.day4_icon,
            this.day5_temp_min, this.day5_temp_max, this.day5_icon, this.day6_temp_min, this.day6_temp_max, this.day6_icon,
            this.day7_temp_min, this.day7_temp_max, this.day7_icon);

  factory WeatherModel.fromJason(Map<String, dynamic> json,Map<String, dynamic> json2, String name, String country, String description, double wind, String icon,
                            Map<String, dynamic> forecast1, Map<String, dynamic> forecast2, Map<String, dynamic> forecast3, Map<String, dynamic> forecast4, Map<String, dynamic> forecast5,
                            Map<String, dynamic> forecast6, Map<String, dynamic> forecast7) {
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
      forecast1['temp']['min'],
      forecast1['temp']['max'],
      forecast1['weather'][0]['icon'],
      forecast2['temp']['min'],
      forecast2['temp']['max'],
      forecast2['weather'][0]['icon'],
      forecast3['temp']['min'],
      forecast3['temp']['max'],
      forecast3['weather'][0]['icon'],
      forecast4['temp']['min'],
      forecast4['temp']['max'],
      forecast4['weather'][0]['icon'],
      forecast5['temp']['min'],
      forecast5['temp']['max'],
      forecast5['weather'][0]['icon'],
      forecast6['temp']['min'],
      forecast6['temp']['max'],
      forecast6['weather'][0]['icon'],
      forecast7['temp']['min'],
      forecast7['temp']['max'],
      forecast7['weather'][0]['icon'],
    );
  }

}