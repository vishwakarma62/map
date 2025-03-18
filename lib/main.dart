
import 'package:flutter/material.dart';
import 'package:map/home_screen.dart';
import 'package:map/tracking_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LiveAnimatedMarkers(),
    );
  }
}
