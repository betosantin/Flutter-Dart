import 'package:flutter/material.dart';
import 'package:buscador_gif/ui/home_page.dart';
import 'package:buscador_gif/ui/gif_page.dart';

void main() {
  runApp(new MaterialApp(
    title: "Buscador de GIFs",
    home: HomePage(),
    theme: ThemeData(hintColor: Colors.white),
  ));
}
