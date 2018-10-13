import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=64a156fc";

void main() async {
  runApp((MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  )));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar = 0.0;
  double euro = 0.0;

  final realControler = TextEditingController();
  final dolarControler = TextEditingController();
  final euroControler = TextEditingController();

  void _realChanged(String text) {
    double real = double.parse(text);
    dolarControler.text = (real / dolar).toStringAsFixed(3).replaceAll(".", ",");
    euroControler.text = (real / euro).toStringAsFixed(3).replaceAll(".", ",");
  }

  void _dolarChanged(String text) {
    double dolar = double.parse(text);
    realControler.text = (dolar * this.dolar).toStringAsFixed(3).replaceAll(".", ",");
    euroControler.text = (dolar * this.dolar / euro).toStringAsFixed(3).replaceAll(".", ",");
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);
    realControler.text = (euro * this.euro).toStringAsFixed(3).replaceAll(".", ",");
    dolarControler.text = (euro * this.euro / dolar).toStringAsFixed(3).replaceAll(".", ",");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Carregando Dados",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao Carregar Dados :(",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          size: 150.0,
                          color: Colors.amber,
                        ),
                        buildTextFiled(
                            "Real", "R\$", realControler, _realChanged),
                        Divider(),
                        buildTextFiled(
                            "Dólar", "\$", dolarControler, _dolarChanged),
                        Divider(),
                        buildTextFiled(
                            "Euro", "£", euroControler, _euroChanged),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextFiled(
    String text, String simbolo, TextEditingController controller, Function f) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: text,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: simbolo,
    ),
    style: TextStyle(color: Colors.amber, fontSize: 30.0),
    keyboardType: TextInputType.number,
    onChanged: f,
  );
}
