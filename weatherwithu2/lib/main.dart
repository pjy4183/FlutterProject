import 'package:flutter/material.dart';
import 'package:weatherwithu2/weatherBloc.dart';
import 'package:weatherwithu2/weatherModel.dart';
import 'package:weatherwithu2/weatherRepo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
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
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme:
            ThemeData(primarySwatch: Colors.blue, canvasColor: Colors.blueGrey
                //visualDensity: VisualDensity.adaptivePlatformDensity,
                ),
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.grey[900],
          body: BlocProvider(
            builder: (context) => WeatherBloc(WeatherRepo()),
            child: SearchPage(),
          ),
        ));
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
      body: Stack(
        children: <Widget>[
          Column(
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25),
                              decoration: InputDecoration(
                                hintText: 'Search location here....',
                                hintStyle: TextStyle(
                                    color: Colors.white, fontSize: 18),
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
                      "Sorry, cannot find the city...",
                      style: TextStyle(color: Colors.white),
                    );
                },
              ),
            ],
          ),
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

class ShowWeather extends StatefulWidget {
  WeatherModel weather;
  final city;

  ShowWeather(this.weather, this.city);
  @override
  _ShowWeatherState createState() => _ShowWeatherState(weather, city);
}

class _ShowWeatherState extends State<ShowWeather>
    with SingleTickerProviderStateMixin {
  var _controller = SnappingSheetController();
  AnimationController _arrowIconAnimationController;
  Animation<double> _arrowIconAnimation;

  double _moveAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _arrowIconAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _arrowIconAnimation = Tween(begin: 0.0, end: 0.2).animate(CurvedAnimation(
        curve: Curves.elasticOut,
        reverseCurve: Curves.elasticIn,
        parent: _arrowIconAnimationController));
  }

  WeatherModel weather;
  final city;

  _ShowWeatherState(this.weather, this.city);

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

    return Stack(
      children: <Widget>[
        Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/$icon.gif"),
                fit: BoxFit.cover,
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
                Stack(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        pic,
                        color: Colors.white,
                        size: 150,
                      ),
                      width: 250,
                      height: 250,
                    ),
                  ],
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
                  height: 20,
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
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
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
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
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
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 30,
                    ),
                    padding: const EdgeInsets.only(right: 15),
                    onPressed: () {
                      _bottomSheet(context);
                    }),
              ],
            )),
      ],
    );
  }

  void _bottomSheet(BuildContext context) {
    final now = DateTime.now();
    var tomorrow = DateTime(now.year, now.month, now.day + 1);
    var formattedDate = "${tomorrow.month}/${tomorrow.day}";
    var tomorrow2 = DateTime(now.year, now.month, now.day + 2);
    var formattedDate2 = "${tomorrow2.month}/${tomorrow2.day}";
    var tomorrow3 = DateTime(now.year, now.month, now.day + 3);
    var formattedDate3 = "${tomorrow3.month}/${tomorrow3.day}";
    var tomorrow4 = DateTime(now.year, now.month, now.day + 4);
    var formattedDate4 = "${tomorrow4.month}/${tomorrow4.day}";
    var tomorrow5 = DateTime(now.year, now.month, now.day + 5);
    var formattedDate5 = "${tomorrow5.month}/${tomorrow5.day}";
    var tomorrow6 = DateTime(now.year, now.month, now.day + 6);
    var formattedDate6 = "${tomorrow6.month}/${tomorrow6.day}";
    var tomorrow7 = DateTime(now.year, now.month, now.day + 7);
    var formattedDate7 = "${tomorrow7.month}/${tomorrow7.day}";
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            color: Colors.black,
            child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(30),
                        topRight: const Radius.circular(30))),
                height: MediaQuery.of(context).size.height * .80,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "$formattedDate",
                          style: TextStyle(fontSize: 17),
                        ),
                        SizedBox(
                          width: 80,
                        ),
                        Image.network(
                          'http://openweathermap.org/img/wn/${weather.day1_icon}@2x.png',
                          width: 40,
                        ),
                        SizedBox(
                          width: 80,
                        ),
                        Text(
                            weather.day1_temp_max.round().toString() +
                                "°C/" +
                                weather.day1_temp_min.round().toString() +
                                "°C",
                            textAlign: TextAlign.end),
                      ],
                    ),
                    Divider(color: Colors.black, indent: 16.0, endIndent: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("$formattedDate2", style: TextStyle(fontSize: 17)),
                        SizedBox(
                          width: 80,
                        ),
                        Image.network(
                            'http://openweathermap.org/img/wn/${weather.day2_icon}@2x.png',
                            width: 40),
                        SizedBox(
                          width: 80,
                        ),
                        Text(weather.day2_temp_max.round().toString() +
                            "°C/" +
                            weather.day2_temp_min.round().toString() +
                            "°C"),
                      ],
                    ),
                    Divider(color: Colors.black, indent: 16.0, endIndent: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("$formattedDate3", style: TextStyle(fontSize: 17)),
                        SizedBox(
                          width: 80,
                        ),
                        Image.network(
                            'http://openweathermap.org/img/wn/${weather.day3_icon}@2x.png',
                            width: 40),
                        SizedBox(
                          width: 80,
                        ),
                        Text(weather.day3_temp_max.round().toString() +
                            "°C/" +
                            weather.day3_temp_min.round().toString() +
                            "°C"),
                      ],
                    ),
                    Divider(color: Colors.black, indent: 16.0, endIndent: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("$formattedDate4", style: TextStyle(fontSize: 17)),
                        SizedBox(
                          width: 80,
                        ),
                        Image.network(
                            'http://openweathermap.org/img/wn/${weather.day4_icon}@2x.png',
                            width: 40),
                        SizedBox(
                          width: 80,
                        ),
                        Text(weather.day4_temp_max.round().toString() +
                            "°C/" +
                            weather.day4_temp_min.round().toString() +
                            "°C"),
                      ],
                    ),
                    Divider(color: Colors.black, indent: 16.0, endIndent: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("$formattedDate5", style: TextStyle(fontSize: 17)),
                        SizedBox(
                          width: 80,
                        ),
                        Image.network(
                            'http://openweathermap.org/img/wn/${weather.day5_icon}@2x.png',
                            width: 40),
                        SizedBox(
                          width: 80,
                        ),
                        Text(weather.day5_temp_max.round().toString() +
                            "°C/" +
                            weather.day5_temp_min.round().toString() +
                            "°C"),
                      ],
                    ),
                    Divider(color: Colors.black, indent: 16.0, endIndent: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("$formattedDate6", style: TextStyle(fontSize: 17)),
                        SizedBox(
                          width: 80,
                        ),
                        Image.network(
                            'http://openweathermap.org/img/wn/${weather.day6_icon}@2x.png',
                            width: 40),
                        SizedBox(
                          width: 80,
                        ),
                        Text(weather.day6_temp_max.round().toString() +
                            "°C/" +
                            weather.day6_temp_min.round().toString() +
                            "°C"),
                      ],
                    ),
                    Divider(color: Colors.black, indent: 16.0, endIndent: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("$formattedDate7", style: TextStyle(fontSize: 17)),
                        SizedBox(
                          width: 80,
                        ),
                        Image.network(
                            'http://openweathermap.org/img/wn/${weather.day7_icon}@2x.png',
                            width: 40),
                        SizedBox(
                          width: 80,
                        ),
                        Text(weather.day7_temp_max.round().toString() +
                            "°C/" +
                            weather.day7_temp_min.round().toString() +
                            "°C"),
                      ],
                    ),
                    Divider(color: Colors.black, indent: 16.0, endIndent: 16.0),
                  ],
                )),
          );
        });
  }
}
