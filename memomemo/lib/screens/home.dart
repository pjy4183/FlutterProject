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
              context, 
              CupertinoPageRoute(
                builder: (context) => EditPage(),
                ),
                ).then((value){
                  setState(() {});
                });
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

  Widget memoBuilder() {
    return FutureBuilder(
      builder: (context, projectSnap) {
        if (projectSnap.data == null) {
          return Container(
            alignment: Alignment.center,
            child: Text(
              'Click "Add Memo" to \ntry to write a note!\n\n\n\n\n\n',
              style: TextStyle(fontSize: 18, color: Colors.blueAccent),
              textAlign: TextAlign.center,
            ),
          );
        }
        return ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: projectSnap.data.length,
          itemBuilder: (context, index) {
            Memo memo = projectSnap.data[index];
            return Container(
              margin: EdgeInsets.all(5),
              padding:  EdgeInsets.all(15),
              alignment: Alignment.center,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(memo.title,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500)),
                      Text(memo.text, style: TextStyle(fontSize: 15)),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text("Last Edited Time: " + memo.editTime.split('.')[0],
                          style: TextStyle(fontSize: 11),
                          textAlign: TextAlign.end,
                      ),
                    ],
                  )
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.blue,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.lightBlue, blurRadius: 3)],
              ),
            );
          },
        );
      },
      future: loadMemo(),
    );
  }
}
