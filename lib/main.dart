import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'homepage.dart';

Future<void> main() async {
  runApp(const MyApp());
  await initializeDateFormatting('id_ID', null);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}
