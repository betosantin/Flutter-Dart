import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main(){
  runApp(MaterialApp(
    home: Home(),
  ));
}
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  void initState() {
    super.initState();

    _readData().then((data){
      setState(() {
        _list = json.decode(data);
      });
    });
  }

  final _textFieldController = TextEditingController();

  List _list = [];
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  void _addLista()
  {
    setState(() {
      Map<String, dynamic> map = new Map();
      map["title"] = _textFieldController.text;
      _textFieldController.text = "";
      map["ok"] = false;

      _list.add(map);
      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                    child: TextField(
                      controller: _textFieldController,
                      decoration: const InputDecoration(
                          labelText: "Nova Tarefa",
                          labelStyle: TextStyle(color: Colors.blueAccent)
                      ),
                    )
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: _addLista,
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _list.length,
                itemBuilder: buildItem
            ), onRefresh: refresh)
          )
        ],
      ),
    );
  }

  Future<Null> refresh() async
  {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _list.sort((a, b) {
        if (a["ok"] && !b["ok"]) {
          return 1;
        } else if (!a["ok"] && b["ok"]) {
          return -1;
        }
        else {
          return 0;
        }
      });

      _saveData();
    });

    return null;
    ;
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime
          .now()
          .millisecondsSinceEpoch
          .toString()),
      background: Container(color: Colors.red,
        child: Align(alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white,),),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_list[index]["title"]),
        value: _list[index]["ok"],
        secondary: CircleAvatar(
          child:
          Icon(_list[index]["ok"] ? Icons.check : Icons.error),
        ), onChanged: (bool value) {
        setState(() {
          _list[index]["ok"] = value;
          _saveData();
        });
      },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_list[index]);
          _lastRemovedPos = index;
          _list.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
            action: SnackBarAction(label: "Desfazer", onPressed: () {
              setState(() {
                _list.insert(_lastRemovedPos, _lastRemoved);
              });
            }),
            duration: Duration(seconds: 2),
          );

          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getFile() async {
    final directiory = await getApplicationDocumentsDirectory();

    return File("${directiory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_list);

    final file = await _getFile();

    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
