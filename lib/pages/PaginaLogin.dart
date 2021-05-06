import 'package:flutter/material.dart';
import 'package:lista_app/pages/PaginaListaDeCompras.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaginaLogin extends StatefulWidget {
  @override
  _PaginaLoginState createState() => _PaginaLoginState();
}

class _PaginaLoginState extends State<PaginaLogin> {
  TextEditingController _controllerLogin = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<String> _textoSalvo;
  String _senhaAtual = "";
  String _usuario = "usuario";
  String _senha = "senha";
  bool flag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de contas"),
      ),
      body: Form( //consegue armazenar o estado dos campos de texto e além disso, fazer a validação
        key: _formKey, //estado do formulário
        child: ListView(
          padding: EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                  labelText: "Login:",
                  hintText: "Digite o login"
              ),
              controller: _controllerLogin,
              validator: (String text){
                if(text.isEmpty){
                  return "Digite o texto";
                }
                else if(_controllerSenha.text.length < 4) {
                  return null;
                }
                else{
                  if(_verificarLogin(text)){
                    _salvarDadosUsuario(text);
                    _salvarDadosSenha(text, _controllerSenha.text);
                    flag = true;
                  }
                  else{
                    return null;
                  }
                }
                return null;
              },
            ),
            SizedBox(height: 10,),
            TextFormField(
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                  labelText: "Senha:",
                  hintText: "Digite a senha"
              ),
              obscureText: true,
              controller: _controllerSenha,
              validator: (String text){
                if(text.isEmpty){
                  return "Digite a senha ";
                }
                else if(text.length < 4){
                  return "A senha tem pelo menos 4 dígitos";
                }
                else{
                  _recuperarDadosSenha( _controllerLogin.text);
                  print("Senha astual: " + _senhaAtual);
                  if(_senhaAtual == text || flag){
                    flag = false;
                    return null;
                  }
                  else{
                    return "Senha incorreta";
                  }
                }
              },
            ),
            SizedBox(height: 20,),
            Container(
              height: 46,
              child: RaisedButton(
                  color: Colors.pink,
                  child: Text("Login",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    ),),
                  onPressed: (){
                    bool formOk = _formKey.currentState.validate();
                    if(! formOk){
                      return;
                    }
                    else{
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PaginaListaDeCompras(_controllerLogin.text)
                          ),
                      );
                    }
                    print("Login "+_controllerLogin.text);
                    print("Senha "+_controllerSenha.text);
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState(){
    _recuperarDadosUsuario();
  }


  _salvarDadosUsuario(String valorDigitado) async{
    final prefs = await SharedPreferences.getInstance();
    _recuperarDadosUsuario();
    _textoSalvo.add(valorDigitado);
    await prefs.setStringList(_usuario, _textoSalvo); // a chave será usada para recuperar dados
    print("Operação salvar: $valorDigitado");
    print(_textoSalvo);
  }

  _salvarDadosSenha(String usuario, String senha) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(usuario, senha); // a chave será usada para recuperar dados
    print("Operação salvar senha: $senha");
  }

  _recuperarDadosUsuario() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _textoSalvo = prefs.getStringList(_usuario) ?? [];
    });
    print("Operação recuperar: $_textoSalvo");
  }

  _recuperarDadosSenha(String usuario) async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _senhaAtual = prefs.getString(usuario) ?? "";
    });
    print("Operação recuperar senha: $_senhaAtual");
  }


  bool _verificarLogin(String s){
    _recuperarDadosUsuario();
    if(_textoSalvo.length == 0){
      return true;
    }
    else{
      for(int i = 0; i < _textoSalvo.length; i++){
        if(s == _textoSalvo[i]){
          return false;
        }
      }
    }
    return true;
  }
}
