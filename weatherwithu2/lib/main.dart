import 'package:flutter/material.dart';
import 'package:weatherwithu2/weatherBloc.dart';
import 'package:weatherwithu2/weatherModel.dart';
import 'package:weatherwithu2/weatherRepo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          //visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.grey[900],
            body: BlocProvider(
              builder: (context) => WeatherBloc(WeatherRepo()),
              child: SearchPage(),
            )));
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  initState() {
    super.initState();
    _getCurrentLocation();
  }

  Widget build(BuildContext context) {
    final weatherBloc = BlocProvider.of<WeatherBloc>(context);
    var cityController = TextEditingController();
    String errorMessage = "";

    return Scaffold(
      backgroundColor: Colors.grey[900],
      resizeToAvoidBottomInset: false,
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                        margin: const EdgeInsets.all(13),
                        height: 45,
                        width: 330,
                        child: TextField(
                          onSubmitted: (String input) {
                            weatherBloc.add(FetchWeather(input));
                          },
                          style: TextStyle(color: Colors.white, fontSize: 25),
                          decoration: InputDecoration(
                            hintText: 'Search location here....',
                            hintStyle:
                                TextStyle(color: Colors.white, fontSize: 18),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white70,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    color: Colors.white70,
                                    style: BorderStyle.solid)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    color: Colors.blue,
                                    style: BorderStyle.solid)),
                          ),
                        )),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 15.0,
                      ),
                    )
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.location_on),
                  color: Colors.white70,
                  iconSize: 38,
                  onPressed: () {
                    _getCurrentLocation();
                  },
                ),
              ]),
          BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) {
              if (state is WeatherIsNotSearch)
                return Container(
                  padding: EdgeInsets.only(
                    left: 32,
                    right: 32,
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: FlareActor(
                          "assets/WorldSpin.flr",
                          fit: BoxFit.contain,
                          animation: "roll",
                        ),
                        height: 300,
                        width: 300,
                      ),
                      Text(
                        "Search Weather",
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70),
                      ),
                      Text(
                        "Instanly",
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w200,
                            color: Colors.white70),
                      ),
                    ],
                  ),
                );
              else if (state is WeatherIsLoading)
                return Center(child: CircularProgressIndicator());
              else if (state is WeatherIsLoaded)
                return ShowWeather(state.getWeather, cityController.text);
              else
                return Text(
                  "Error",
                  style: TextStyle(color: Colors.white),
                );
            },
          )
        ],
      ),
    );
  }

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  Position _currentPosition;
  String _currentAddress;
  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      final weatherBloc = BlocProvider.of<WeatherBloc>(context);
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
      weatherBloc.add(FetchWeather(place.locality));
      
    } catch (e) {
      print(e);
    }
  }
}

class ShowWeather extends StatelessWidget {
  WeatherModel weather;
  final city;

  ShowWeather(this.weather, this.city);
  
  @override
  Widget build(BuildContext context) {

    String icon = weather.icon;
    IconData pic = WeatherIcons.day_lightning;
    if (icon == '01d' || icon == '01n') {
      if (icon == '01d')
        pic = WeatherIcons.day_sunny;
      else
        pic = WeatherIcons.night_clear;
    }
    if (icon == '02d' || icon == '02n') {
      if (icon == '02d')
        pic = WeatherIcons.day_cloudy;
      else
        pic = WeatherIcons.night_alt_cloudy;
    }
    if (icon == '03d' || icon == '03n') {
      pic = WeatherIcons.cloud;
    }
    if (icon == '04d' || icon == '04n') {
      pic = WeatherIcons.cloudy;
    }
    if (icon == '09d' || icon == '09n') {
      if (icon == '09d')
        pic = WeatherIcons.day_rain;
      else
        pic = WeatherIcons.night_alt_rain_wind;
    }
    if (icon == '10d' || icon == '10n') {
      if (icon == '10d')
        pic = WeatherIcons.day_sleet;
      else
        pic = WeatherIcons.night_alt_sleet;
    }
    if (icon == '11d' || icon == '11n') {
      if (icon == '11d')
        pic = WeatherIcons.day_storm_showers;
      else
        pic = WeatherIcons.night_storm_showers;
    }
    if (icon == '13d' || icon == '13n') {
      if (icon == '13d')
        pic = WeatherIcons.day_snow_wind;
      else
        pic = WeatherIcons.night_snow_wind;
    }
    if (icon == '50d' || icon == '50n') {
      pic = WeatherIcons.fog;
    }
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/$icon.png"), 
                fit: BoxFit.fitWidth,
                alignment: Alignment.center,
              ),
              
              shape: BoxShape.circle,
            ),
        padding: EdgeInsets.only(right: 32, left: 32, top: 10),
        child: Column(
          children: <Widget>[
            Text(
              weather.name + '/' + weather.country,
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                  color: Colors.lightGreenAccent),
            ),
            Container(
              child: Icon(
                pic,
                color: Colors.white,
                size: 150,
              ),
              width: 250,
              height: 250,
            ),
            Text(
              weather.description.toString(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              weather.temp.round().toString() + "°C",
              style: TextStyle(color: Colors.white, fontSize: 50),
            ),
            Text(
              "( min " +
                  weather.temp_min.round().toString() +
                  "°C / " +
                  "max " +
                  weather.temp_max.round().toString() +
                  "°C )",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 100,
                  height: 140,
                  padding: const EdgeInsets.all(6.0),
                  margin: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightGreenAccent),
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Icon(
                        WeatherIcons.humidity,
                        color: Colors.lightBlue,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        weather.humidity.round().toString() + " %",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Humidity",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 100,
                  height: 140,
                  padding: const EdgeInsets.all(3.0),
                  margin: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightGreenAccent),
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Icon(
                        WeatherIcons.strong_wind,
                        color: Colors.blueAccent,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            weather.wind.toStringAsFixed(1).toString(),
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "m/s",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Wind Speed",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 100,
                  height: 140,
                  padding: const EdgeInsets.all(3.0),
                  margin: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightGreenAccent),
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Icon(
                        WeatherIcons.thermometer,
                        color: Colors.redAccent,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        weather.feels_like.round().toString() + "°C",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Feels Like",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
