import 'package:flutter/material.dart';
import 'api_doc_generator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'REST API Doc Creator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
  style: ButtonStyle(
    backgroundColor: WidgetStateProperty.all(Colors.blue),
    foregroundColor: WidgetStateProperty.all(Colors.white),
    elevation: WidgetStateProperty.all(4),
    padding: WidgetStateProperty.all(
      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),
),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.white
        ),
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: ApiDocGenerator(),
    );
  }
}
