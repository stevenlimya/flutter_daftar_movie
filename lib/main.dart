import 'package:flutter/material.dart';
import 'package:flutter_daftar_movie/screens/favorite_screen.dart';
import 'package:flutter_daftar_movie/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const FavoriteScreen(),
    );
  }
}
