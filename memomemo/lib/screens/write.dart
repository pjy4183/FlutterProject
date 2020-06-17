import 'package:flutter/material.dart';
import 'package:memomemo/database/memo.dart';
import 'package:memomemo/database/db.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';


class WritePage extends StatelessWidget {
  String title = '';
  String text = '';
  BuildContext _context;
  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      resizeToAvoidBottomInset: false,
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: saveDB,
            )
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              TextField(
                onChanged: (String title){ this.title = title;},
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
                keyboardType: TextInputType.multiline,
                maxLines: 2,
                decoration: InputDecoration(hintText: 'Title'),
              ),
              Padding(padding: EdgeInsets.all(10)),
              TextField(
                onChanged: (String text){ this.text = text;},
                keyboardType: TextInputType.multiline,
                maxLines: 8,
                decoration: InputDecoration(hintText: 'Contents'),
              )
            ],
          ),
        ));
  }

  Future<void> saveDB() async {

    DBHelper sd = DBHelper();

    var fido = Memo(
      id: Str2Sha512(DateTime.now().toString()),
      title: this.title,
      text: this.text,
      createTime: DateTime.now().toString(),
      editTime: DateTime.now().toString(),
    );

    await sd.insertMemo(fido);

    print(await sd.memos());
    Navigator.pop(_context);
  }

  String Str2Sha512(String text) { //Convert String to hash code
    var bytes = utf8.encode(text); 
    var digest = sha512.convert(bytes);
    return digest.toString();
  }
}
