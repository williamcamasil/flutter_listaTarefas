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
  List _toDoList = [];

  //Função que irá retornar o arquivo para salvar
  Future<File> _getFile() async {
    //Pegar o diretorio onde se pode armazenar os docs do app
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  //Função para salvar os dados
  Future<File> _saveData() async {
    //Convertendo a lista em json
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  //Função para fazer a leitura dos dados
  Future<String> _readData() async{
    try{
      final file = await _getFile();
      return file.readAsString();

    }catch (e) {
      return null;
    }
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
            padding: EdgeInsetsDirectional.fromSTEB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                //Expanded identifica o quanto é necessário expandir para que fique rente a tela
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),                

                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: () {

                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

