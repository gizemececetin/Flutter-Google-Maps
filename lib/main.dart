import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'directions_provider.dart';
import 'home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DirectionProvider(),
      child: MaterialApp(
          theme: ThemeData(
            primaryColor: Colors.deepPurple,
          ),
          debugShowCheckedModeBanner: false,
          title: 'Maps Product',
          home: Home(),
      ),
    );
  }
}
