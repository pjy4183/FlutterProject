import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'edit.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Row(children: <Widget>[
            Padding(padding: EdgeInsets.only(left:20, top:20, bottom:20),
            child: Text('Memomemo', style: TextStyle(fontSize: 36, color:Colors.blue)),)
          ],),
         ...LoadMemo()
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => EditPage())
          );
        },
        tooltip: 'Click if you need to add memo',
        label: Text('Add Memo'),
        icon: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  List<Widget> LoadMemo() {
    List<Widget> memoList = [];
    memoList.add(Container(color: Colors.deepPurple, height:150,));
    return memoList;
  }
}
