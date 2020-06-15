import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'edit.dart';
import 'package:memomemo/database/db.dart';
import 'package:memomemo/database/memo.dart';

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
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 5, top: 30, bottom: 20),
            child: Container(
              child: Text('Memomemo',
                style: TextStyle(fontSize: 36, color: Colors.blue)),
                alignment: Alignment.centerLeft,
            ),
          ),
          Expanded(child: memoBuilder()),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => EditPage()));
        },
        tooltip: 'Click if you need to add memo',
        label: Text('Add Memo'),
        icon: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  List<Widget> LoadMemo() {
    List<Widget> memoList = [];
    memoList.add(Container(
      color: Colors.deepPurple,
      height: 150,
    ));
    return memoList;
  }

  Future<List<Memo>> loadMemo() async {
    DBHelper sd = DBHelper();
    return await sd.memos();
  }

  Widget memoBuilder(){
    return FutureBuilder(
      builder: (context, projectSnap){
        if (projectSnap.data.isEmpty) {
            return Container(
              alignment: Alignment.center,
              child: Text('Click "Add Memo" to \ntry to write a note!\n\n\n\n\n\n', 
                style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                textAlign: TextAlign.center,),);
        }
        return ListView.builder(
          itemCount: projectSnap.data.length,
          itemBuilder: (context, index) {
            Memo memo = projectSnap.data[index];
            return Container(
              child: Column(
              children: <Widget>[
                Text(memo.title),
                Text(memo.text),
                Text(memo.createTime)
              ],
            ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.blue,
                  width: 8,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              
            );
          },
        );
      },
      future: loadMemo(),
    );
  }
}
