import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();
  List _toDoList = [];

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState() {
    super.initState(); //o "super" se refere ao state(que é a superclasse daqui)

    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _toDoController.text;
      _toDoController.text = "";
      newToDo["ok"] = false;
      _toDoList.add(newToDo);
      _saveData();
      print('Item salvo!');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _toDoController,
                    decoration: InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
                RaisedButton(
                  onPressed: _addToDo,
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.only(top: 1.0),
                itemCount: _toDoList.length,
                itemBuilder: buildItem),
          ),
        ],
      ),
    );
  }

  Widget buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(-0.9, 0.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          )),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(
            _toDoList[index]["ok"] ? Icons.check : Icons.error,
          ),
        ),
        onChanged: (checked) {
          setState(() {
            _toDoList[index]["ok"] = checked;
            _saveData();
            print('Salvo!');
          });
        },
      ),
      onDismissed: ((direction) {
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;

          _saveData();

          final snack = SnackBar(
                content: Text("Tarefa \"${_lastRemoved[title]}\" removida!"),
                action: SnackBarAction(
                  label: "Desfazer",
                  onPressed: () {
                    setState(() {
                      _toDoList.insert(_lastRemovedPos, _lastRemoved);
                      _saveData();
                    });
                  },
                ),
                duration: Duration(seconds: 2),
              ),
          Scaffold.of(context).showSnackBar.snack;
        });
      }),
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(json.encode("${directory.path}/data.json"));
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    print('encontrei!');

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
