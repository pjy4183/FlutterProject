import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int temperature = 28;
  String location = 'Las Vegas';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/clear.png'),
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
