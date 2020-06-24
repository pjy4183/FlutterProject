import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int temperature;
  String location = 'San Fransisco';
  int woeid = 2487956;
  String status = 'clear';
  String icon = '';
  String errorMessage ='';

  String searchURL = 'https://www.metaweather.com/api/location/search/?query=';
  String locationURL = 'https://www.metaweather.com/api/location/';

  initState() {
    super.initState();
    fetchLocation();
  }

  void fetchSearch( String input) async {
    try{
      var searchResult = await http.get(searchURL + input);
      var result = json.decode(searchResult.body)[0];

      setState(() {
        location = result['title'];
        woeid = result['woeid'];
        errorMessage ='';
      });
    }
    catch(error){
      setState(() {
        errorMessage = "Sorry, cannot find the city...";
      });
    }
  }

  void fetchLocation() async {
    var locationResult = await http.get(locationURL + woeid.toString());
    var result = json.decode(locationResult.body);
    var data = result['consolidated_weather'][0];

    setState(() {
      temperature = data['the_temp'].round();
      status = data['weather_state_name'].replaceAll(' ', '').toLowerCase();
      icon = data['weather_state_abbr'];
    });
  }

  void onTextFieldSubmitted(String input) async{
    await fetchSearch(input);
    await fetchLocation();
  }

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
        child: temperature==null ? Center(child: CircularProgressIndicator()): Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Center(
                    child: Image.network(
                      'https://www.metaweather.com/static/img/weather/png/' +icon +'.png',
                      width: 100,
                    ),
                  ),
                  Center(
                    child: Text(
                      temperature.toString() + '°C',
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
                        hintText: 'Search location here....',
                        hintStyle: TextStyle(color: Colors.white, fontSize: 18),
                        prefixIcon: Icon(Icons.search, color: Colors.white), 
                      ),
                    )
                  ),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.redAccent, fontSize: Platform.isAndroid ? 15.0: 20.0
                    ),
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
