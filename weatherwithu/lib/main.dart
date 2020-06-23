import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
<<<<<<< HEAD
  int temperature = 30;
  String location = 'Las Vegas';
=======
  int temperature = 0;
  String location = 'San Fransisco';
  int woeid = 2487956;
  String status = 'clear';

  String searchURL = 'https://www.metaweather.com/api/location/search/?query=';
  String locationURL = 'https://www.metaweather.com/api/location/';

  void fetchSearch( String input) async {
    var searchResult = await http.get(searchURL + input);
    var result = json.decode(searchResult.body)[0];

    setState(() {
      location = result['title'];
      woeid = result['woeid'];
    });
  }

  void fetchLocation() async {
    var locationResult = await http.get(locationURL + woeid.toString());
    var result = json.decode(locationResult.body);
    var data = result['consolidated_weather'][0];

    setState(() {
      temperature = data['the_temp'].round();
      status = data['weather_state_name'].replaceAll(' ', '').toLowerCase();
    });
    print(temperature);
  }

  void onTextFieldSubmitted(String input){
    fetchSearch(input);
    fetchLocation();
  }

>>>>>>> Getting API
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/$status.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Center(
                    child: Text(
                      temperature.toString() + '°Celcius',
                      style: TextStyle(color: Colors.white, fontSize: 60),
                    ),
                  ),
                  Center(
                    child: Text(
                      location,
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Container(
                    width: 300,
                    child: TextField(
                      onSubmitted: (String input){
                        onTextFieldSubmitted(input);
                      },
                      style: TextStyle(color: Colors.white, fontSize: 25),
                      decoration: InputDecoration(
                        hintText: 'Search location here...',
                        hintStyle: TextStyle(color: Colors.white, fontSize: 18),
                        prefixIcon: Icon(Icons.search, color: Colors.white), 
                      ),
                    )
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
