import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'write.dart';
import 'package:memomemo/database/memo.dart';
import 'package:memomemo/database/db.dart';
import 'package:memomemo/screens/view.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String deleteId = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 5, top: 30, bottom: 20),
            child: Container(
              child: Text('MemoChild',
                  style: TextStyle(fontSize: 36, color: Colors.blue)),
              alignment: Alignment.centerLeft,
            ),
          ),
          Expanded(child: memoBuilder(context)),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => WritePage(),
            ),
          ).then((value) {
            setState(() {});
          });
        },
        tooltip: 'Click if you need to add memo',
        label: Text('Add Memo'),
        icon: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<List<Memo>> loadMemo() async {
    DBHelper sd = DBHelper();
    return await sd.memos();
  }

  Future<void> deleteMemo(String id) async {
    DBHelper sd = DBHelper();
    sd.deleteMemo(id);
  }

  void showAlertDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert Delete'),
          content: Text(
              "Are you really want to delete?\nDeleted file cannot be recovered."),
          actions: <Widget>[
            FlatButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.pop(context, "Delete");
                setState(() {
                  deleteMemo(deleteId);
                });
                deleteId = '';
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                deleteId = '';
                Navigator.pop(context, "Cancel");
              },
            ),
          ],
        );
      },
    );
  }

  Widget memoBuilder(BuildContext parentContext) {
    return FutureBuilder(
      builder: (context, projectSnap) {
        if (projectSnap.data == null || projectSnap.data.isEmpty) {
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
          padding: EdgeInsets.all(20),
          itemCount: projectSnap.data.length,
          itemBuilder: (context, index) {
            Memo memo = projectSnap.data[index];
            return InkWell(
                onTap: () {
                  Navigator.push(
                      parentContext,
                      CupertinoPageRoute(
                          builder: (context) => ViewPage(id: memo.id)));
                },
                onLongPress: () {
                  deleteId = memo.id;
                  showAlertDialog(parentContext);
                },
                child: Container(
                  margin: EdgeInsets.all(5),
                  padding: EdgeInsets.all(15),
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
                                  fontSize: 20, 
                                  fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,  ),
                          Text(
                            memo.text, 
                            style: TextStyle(fontSize: 15),
                            overflow: TextOverflow.ellipsis,  
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            "Last Edited Time: " + memo.editTime.split('.')[0],
                            style: TextStyle(fontSize: 11),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(230, 230, 230, 1),
                    border: Border.all(
                      color: Colors.blue,
                      width: 1,
                    ),
                    
                    boxShadow: [
                      BoxShadow(color: Colors.lightBlue, blurRadius: 3)
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ));
          },
        );
      },
      future: loadMemo(),
    );
  }
}
