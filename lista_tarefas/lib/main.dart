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

  final _toDoController = TextEditingController();

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  //Recupera os dados salvos no app
  @override
  void initState(){
    super.initState();
    //Função anonima
    _readData().then((data) {
      _toDoList = json.decode(data);
    });
  }

  void _addToDo(){
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _toDoController.text;
      _toDoController.text = "";
      newToDo["ok"] = false;
      _toDoList.add(newToDo);

      _saveData();
    });
  }


  //Função que não retorna nada
  Future<Null> _refresh() async{
    //Se estiver puxando do servidor não precisa colocar esse time
    //por o próprio servidor já tem isso
    await Future.delayed(Duration(seconds: 1));
    
    setState(() {
      //Ordenando a lista
      _toDoList.sort((a,b) {
        if(a["ok"] && !b["ok"]) return 1;
        else if(!a["ok"] && b["ok"]) return 1;
        else return 0;
      });

      _saveData();  
    });

    return null;

  }

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
                    controller: _toDoController,
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
                  onPressed: _addToDo,
                ),
              ],
            ),
          ),

          Expanded(
            //Serve para atualizar a lista ao arrastar para baixo
            child: RefreshIndicator(
              //Criado uma lista que será construindo conforme for adicionando itens
              child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                //Pegando o tamanho da lista
                itemCount: _toDoList.length,
                //O context tem os dados e o index o indice do item clicado na lista
                //Criado função para ser usada
                itemBuilder: buildItem, 
              ),
              //Passando a função para o refresh
              onRefresh: _refresh,
            
            )
          
          ),
        ],
      ),
    );
  }

  //Cria cada item da lista
  Widget buildItem(BuildContext context, int index){
    //Permite que deslize o item para o lado, neste caso para exclusão
    return Dismissible(
      //É usado para identificar qual é o item selecionado
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        //Alinha o conteudo na borda
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),

      //Direção que será deslizada
      direction: DismissDirection.startToEnd,

      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(
            _toDoList[index]["ok"] ? Icons.check : Icons.error
          ),
        ),
        //Habilita a mudança do checkbox
        onChanged: (c){
          setState(() {
            _toDoList[index]["ok"] = c;
            _saveData();
          });
        },
      ),

      //Função que será chamada sempre que arrastar o item para direita
      //foi passado um parametro para a direção
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
            action: SnackBarAction(label: "Desfazer", 
              onPressed:() {
                setState(() {
                  _toDoList.insert(_lastRemovedPos, _lastRemoved);
                  _saveData();
                });
              }
            ),
            //Duração de tempo que ficará na tela
            duration: Duration(seconds: 2),
          );

          //Mostrar o snackbar na tela
          Scaffold.of(context).removeCurrentSnackBar();
        });
      },
    );
  }
}


  
