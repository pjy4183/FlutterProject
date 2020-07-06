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
          SnappingSheet(
                      sheetBelow: SnappingSheetContent(
                        child: Container(
                            color: Colors.red,
                        ),
                        heightBehavior: SnappingSheetHeight.fit()
                      ),
                    ),
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
    _arrowIconAnimationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _arrowIconAnimation = Tween(begin: 0.0, end: 0.2).animate(CurvedAnimation(
      curve: Curves.elasticOut, 
      reverseCurve: Curves.elasticIn,
      parent: _arrowIconAnimationController)
    );
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

        SnappingSheet(
        sheetAbove: SnappingSheetContent(
          child: Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Align(
              alignment: Alignment(0.90, 1.0),
              child: FloatingActionButton(
                onPressed: () {
                  if(_controller.snapPositions.last != _controller.currentSnapPosition) {
                    _controller.snapToPosition(_controller.snapPositions.last);
                  } 
                  else {
                    _controller.snapToPosition(_controller.snapPositions.first);
                  }
                },
                child: RotationTransition(
                  child: Icon(Icons.arrow_upward),
                  turns: _arrowIconAnimation,
                ),
              ),
            ),
          ),
        ),
        onSnapEnd: () {
          if(_controller.snapPositions.last != _controller.currentSnapPosition) {
            _arrowIconAnimationController.reverse();
          }
          else {
            _arrowIconAnimationController.forward();
          }
        },
        onMove: (moveAmount) {
          setState(() {
            _moveAmount = moveAmount;
          });
        },
        snappingSheetController: _controller,
        snapPositions: const [
          SnapPosition(positionPixel: 0.0, snappingCurve: Curves.elasticOut, snappingDuration: Duration(milliseconds: 750)),
          SnapPosition(positionFactor: 0.4),
          SnapPosition(positionFactor: 0.8),
        ],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Moved ${_moveAmount.round()} pixels',
              style: TextStyle(fontSize: 20.0),
            ),
          ],
        ),
        grabbingHeight: MediaQuery.of(context).padding.bottom + 50,
        grabbing: GrabSection(),
        sheetBelow: SnappingSheetContent(
          child: SheetContent()
        ),
      ),

        Container(
            // decoration: BoxDecoration(
            //     image: DecorationImage(
            //         image: AssetImage("images/$icon.png"), 
            //         fit: BoxFit.fitWidth,
            //         alignment: Alignment.center,
            //       ),
                  
            //       shape: BoxShape.circle,
            //     ),
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
            )),
      ],
    );
  }
}


class SheetContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: EdgeInsets.all(20.0),
        itemCount: 7,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300], width: 1.0))
            ),
            child: ListTile(
              leading: Icon(Icons.info),
              title: Text('List item $index'),
            ),
          );
        },
      ),
    );
  }
}


class GrabSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
          blurRadius: 20.0,
          color: Colors.black.withOpacity(0.2),
        )],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: 100.0,
            height: 10.0,
            margin: EdgeInsets.only(top: 15.0),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.all(Radius.circular(5.0))
            ),
          ),
          Container(
            height: 2.0,
            margin: EdgeInsets.only(left: 20, right: 20),
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}


