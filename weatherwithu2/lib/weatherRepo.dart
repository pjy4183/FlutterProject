import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:weatherwithu2/weatherModel.dart';

class WeatherRepo {
  Future<WeatherModel> getWeather(String city) async{
    var url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=f69167b991bfeed068e309a6b69cd883';
    final result = await http.Client().get(url);

    final jsonDecoded1 = json.decode(result.body);
    var lat = jsonDecoded1['coord']['lat'].toString();
    var lon = jsonDecoded1['coord']['lon'].toString();
    var url2 = 'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&units=metric&exclude=current,minutely,hourly&appid=f69167b991bfeed068e309a6b69cd883';
    final result2 = await http.get(url2);
    if (result.statusCode != 200)
      throw Exception();

    return parseJson(result.body, result2.body);
  }

  WeatherModel parseJson(final response, final response2) {
    final jsonDecoded = json.decode(response);
    final jsonDecoded2 = json.decode(response2);
    
    final data1 = jsonDecoded['coord'];
    final data2 = jsonDecoded['main'];
    final description = jsonDecoded['weather'][0]['description'];
    final city = jsonDecoded['name'];
    final country = jsonDecoded['sys']['country'];
    final wind = jsonDecoded['wind']['speed'];
    final icon = jsonDecoded['weather'][0]['icon'];
    
    final forecast1 = jsonDecoded2['daily'][1];
    final forecast2 = jsonDecoded2['daily'][2];
    final forecast3 = jsonDecoded2['daily'][3];
    final forecast4 = jsonDecoded2['daily'][4];
    final forecast5 = jsonDecoded2['daily'][5];
    final forecast6 = jsonDecoded2['daily'][6];
    final forecast7 = jsonDecoded2['daily'][7];



    return WeatherModel.fromJason(data2, data1, city, country, description, wind, icon, forecast1, forecast2, forecast3, forecast4, forecast5, forecast6, forecast7);
  }
  
}