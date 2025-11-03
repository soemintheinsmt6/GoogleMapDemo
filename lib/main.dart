import 'package:flutter/material.dart';
import 'package:flutter_google_map/core/config/app_constants.dart';
import 'package:flutter_google_map/features/map/presentation/pages/map_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kDefaultThemeColor),
        useMaterial3: true,
      ),
      home: const MapPage(),
    );
  }
}
