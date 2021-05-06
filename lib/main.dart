import 'package:flutter/material.dart';

import 'pages/PaginaLogin.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.pink,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
    ),
    home: PaginaLogin(),
  ));
}