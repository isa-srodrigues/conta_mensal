import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class PaginaListaDeCompras extends StatefulWidget {
  String usuario;
  PaginaListaDeCompras(this.usuario);
  @override
  _PaginaListaDeComprasState createState() => _PaginaListaDeComprasState();
}

class _PaginaListaDeComprasState extends State<PaginaListaDeCompras> {
  TextEditingController _controllerTarefa = TextEditingController();
  List _listaCompras = [];
  List _idCompras = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de contas"),
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.endDocked, //usar com o BottomNavigationBar
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.pinkAccent,
          elevation: 6,
          child: Icon(Icons.add),
          //mini:true,
          //floatingActionButton: FloatingActionButton.extended(
          //icon: Icon(Icons.shopping_cart),
          //label: Text("Adicionar"),
          /*shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.circular(6)
          ),*/
          onPressed: () {
            print("Botão pressionado!");
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Adicionar item: "),
                    content: TextField(
                      decoration: InputDecoration(
                          labelText: "Digite seu item"
                      ),
                      controller: _controllerTarefa,
                    ),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cancelar")
                      ),
                      FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _listaCompras.add(_controllerTarefa.text);
                            _salvarDados(
                                widget.usuario, _controllerTarefa.text);
                            _change();
                          },
                          child: Text("Salvar")
                      ),
                    ],

                  );
                }
            );
          }
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                itemCount: _listaCompras.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Text(_listaCompras[index]),
                      onLongPress: () {
                        print("Botão pressionado!");
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Alterar item: "),
                                content: TextField(
                                  decoration: InputDecoration(
                                      labelText: "Digite seu item"
                                  ),
                                  controller: _controllerTarefa,
                                ),
                                actions: <Widget>[

                                  FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("Cancelar")
                                  ),
                                  FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _change();
                                        _excluirUsuario(_idCompras[index]);
                                        _listaCompras.removeAt(index);
                                        _idCompras.removeAt(index);
                                        print(_listaCompras);
                                        _change();
                                      },
                                      child: Text("Apagar")
                                  ),
                                  FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _listaCompras[index] = _controllerTarefa.text;
                                        _atualizarTarefa(_idCompras[index], _controllerTarefa.text);
                                        _change();
                                      },
                                      child: Text("Salvar")
                                  ),
                                ],

                              );
                            }
                        );
                      }
                  );
                }
            ),
          ),
        ],
      ),


      /*bottomNavigationBar: BottomAppBar(
        //shape: CircularNotchedRectangle(),
        child: Row(
          children: <Widget>[
            IconButton(
                icon:Icon(Icons.add) ,
                onPressed: (){
                }
            ),
          ],
        ),

      ),*/
    );
  }

  @override
  void initState() {
    _listarTarefasini(widget.usuario);
  }


  void _change() {
    setState(() {
      _controllerTarefa.text = "";
    });
  }

  _recuperarBancoDados() async {
    final caminhoBancoDados = await getDatabasesPath();
    final localBancoDados = join(caminhoBancoDados, "banco.bd");
    var bd = await openDatabase(
        localBancoDados,
        version: 1,
        onCreate: (db, dbVersaoRecente) {
          String sql = "CREATE TABLE lista (id INTEGER PRIMARY KEY AUTOINCREMENT, usuario VARCHAR, tarefa VARCHAR) ";
          db.execute(sql);
        }
    );
    return bd;
    //print("aberto: " + bd.isOpen.toString() );
  }

  _salvarDados(String usuario, String tarefa) async {
    Database bd = await _recuperarBancoDados();
    Map<String, dynamic> dadosUsuario = {
      "usuario": usuario,
      "tarefa": tarefa
    };
    int id = await bd.insert("lista", dadosUsuario);
    _idCompras.add(id);
    print("Salvo: $id");
  }


  _listarTarefasini(String usuario) async {
    Database bd = await _recuperarBancoDados();
    try {
      String sql = "SELECT * FROM lista WHERE usuario='$usuario'";
      List tarefas = await bd.rawQuery(
          sql); //conseguimos escrever a query que quisermos
      for (var usu in tarefas) {
        _listaCompras.add(usu['tarefa']);
        _idCompras.add(usu['id']);
        _change();
      }
    }
    catch (e) {

    }
  }


  _excluirUsuario(int id) async {
    Database bd = await _recuperarBancoDados();
    int retorno = await bd.delete(
        "lista",
        where: "id = ?", //caracter curinga
        whereArgs: [id]
    );
    print("Itens excluidos: " + retorno.toString() + " $id");
  }

  _atualizarTarefa(int id, String tarefa) async {
    Database bd = await _recuperarBancoDados();
    Map<String, dynamic> dadosUsuario = {
      "usuario" : widget.usuario,
      "tarefa": tarefa,
    };
    int retorno = await bd.update(
        "lista", dadosUsuario,
        where: "id = ?", //caracter curinga
        whereArgs: [id]
    );
    print("Itens atualizados: " + retorno.toString());
  }


}