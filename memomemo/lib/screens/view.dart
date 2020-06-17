import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:memomemo/database/memo.dart';
import 'package:memomemo/database/db.dart';
import 'package:memomemo/screens/edit.dart';
import 'package:memomemo/screens/home.dart';


class ViewPage extends StatefulWidget {
  ViewPage({Key key, this.id}) : super(key: key);

  final String id;

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  BuildContext _context;
  
  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: showAlertDialog,
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => EditPage(id: widget.id)));
              },
            )
          ],
        ),
        body: Padding(padding: EdgeInsets.all(20), child: loadBuilder()));
  }

  Future<List<Memo>> loadMemo(String id) async {
    DBHelper sd = DBHelper();
    return await sd.findMemo(id);
  }

  loadBuilder() {
    return FutureBuilder<List<Memo>>(
      future: loadMemo(widget.id),
      builder: (BuildContext context, AsyncSnapshot<List<Memo>> snapshot) {
        if (snapshot.data == null || snapshot.data == []) {
          return Container(child: Text("Cannot load Data."));
        } else {
          Memo memo = snapshot.data[0];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                height: 70,
                child: SingleChildScrollView(
                  child: Text(
                    memo.title,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Text(
                "Created Time: " + memo.createTime.split('.')[0],
                style: TextStyle(fontSize: 11),
                textAlign: TextAlign.end,
              ),
              Text(
                "Last Edited Time: " + memo.editTime.split('.')[0],
                style: TextStyle(fontSize: 11),
                textAlign: TextAlign.end,
              ),
              Padding(padding: EdgeInsets.all(10)),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(memo.text),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Future<void> deleteMemo(String id) async {
    DBHelper sd = DBHelper();
    await sd.deleteMemo(id);
  }

  void showAlertDialog() async {
    await showDialog(
      context: _context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert Delete'),
          content: Text("Are you really want to delete?\nDeleted file will not be recovered."),
          actions: <Widget>[
            FlatButton(
              child: Text('Delete'),
              onPressed: () {
                setState(() {
                  Navigator.pop(context, "Delete");
                  deleteMemo(widget.id);
                });
                Navigator.push(
                    _context,
                    CupertinoPageRoute(
                        builder: (_context) => MyHomePage()));
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context, "Cancel");
              },
            ),
          ],
        );
      },
    );
  }
}
