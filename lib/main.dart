import 'package:bank_app/pages/public_page.dart';
import 'package:flutter/material.dart';
import 'pages/root_app.dart';
import 'theme/colors.dart';

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
      title: 'Mobile Banking App',
      theme: ThemeData(
        primaryColor: AppColor.primary,
        brightness: Brightness.light,
      ),
      home: const PublicPage(),
    );
  }
}
