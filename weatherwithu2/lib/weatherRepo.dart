import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:weatherwithu2/weatherModel.dart';

class WeatherRepo {
  Future<WeatherModel> getWeather(String city) async{
    var url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=f69167b991bfeed068e309a6b69cd883';
    final result = await http.Client().get(url);

    if (result.statusCode != 200)
      throw Exception();

    return parseJson(result.body);
  }

  WeatherModel parseJson(final response) {
    final jsonDecoded = json.decode(response);

    final data1 = jsonDecoded['coord'];
    final data2 = jsonDecoded['main'];
    final description = jsonDecoded['weather'][0]['description'];
    final city = jsonDecoded['name'];
    final country = jsonDecoded['sys']['country'];
    final wind = jsonDecoded['wind']['speed'];
    final icon = jsonDecoded['weather'][0]['icon'];

    return WeatherModel.fromJason(data2, data1, city, country, description, wind, icon);
  }
}