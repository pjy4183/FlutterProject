import 'package:flutter/material.dart';
import 'package:weatherwithu2/weatherBloc.dart';
import 'package:weatherwithu2/weatherModel.dart';
import 'package:weatherwithu2/weatherRepo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:geolocator/geolocator.dart';
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
    return Container(
        padding: EdgeInsets.only(right: 32, left: 32, top: 10),
        child: Column(
          children: <Widget>[
            Text(
              weather.name + '/'+ weather.country,
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue),
            ),
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
              weather.name + '/' + weather.country.toString(),
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              weather.temp.round().toString() + "°C",
              style: TextStyle(color: Colors.white70, fontSize: 50),
            ),
            Text(
              "(min " + weather.temp_min.round().toString() + "°C/ " + "max " + weather.temp_max.round().toString() + "°C)",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              weather.description.toString(),
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(
                      weather.temp_min.round().toString() + "°C",
                      style: TextStyle(color: Colors.white70, fontSize: 30),
                    ),
                    Text(
                      "Min Temprature",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(
                      weather.temp_max.round().toString() + "°C",
                      style: TextStyle(color: Colors.white70, fontSize: 30),
                    ),
                    Text(
                      "Max Temprature",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              height: 50,
              child: FlatButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                onPressed: () {
                  BlocProvider.of<WeatherBloc>(context).add(ResetWeather());
                },
                color: Colors.lightBlue,
                child: Text(
                  "Search",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            )
          ],
        ));
  }
}
