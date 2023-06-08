import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:http/http.dart' as http;

import 'home_page.dart';

class CodePage extends StatefulWidget {
  CodePage({Key? key, required this.phoneNumber}) : super(key: key);
  late final String phoneNumber;

  @override
  State<CodePage> createState() => _CodePageState();
}

class _CodePageState extends State<CodePage> {
  late int _code;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                Image.asset(
                  'assets/images/otp_icon.png',
                  height: screenHeight * 0.3,
                  fit: BoxFit.contain,
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                const Text(
                  'Verification',
                  style: TextStyle(fontSize: 28, color: Colors.black),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                Text(
                  'Entrez votre code secret',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.04,
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: screenWidth > 600 ? screenWidth * 0.2 : 16),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0),
                          blurRadius: 6.0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(16.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: screenWidth * 0.025),
                        child: PinEntryTextField(
                          fields: 4,
                          onSubmit: (text) {
                            _code = int.parse(text);
                          },
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.04,
                      ),
                      GestureDetector(
                        onTap: () {
                          verifyCode();
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          height: 45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 253, 188, 51),
                            borderRadius: BorderRadius.circular(36),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Vérifier',
                            style: TextStyle(
                                color: Colors.black, fontSize: 16.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> verifyCode() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.69:8000/bank/clients/'),
    );

    if (response.statusCode == 200) {
      final clients = jsonDecode(response.body) as List<dynamic>;
      final client = clients.firstWhere(
            (c) => c['contact'] == widget.phoneNumber && c['code_secret'] == _code.toString(),
        orElse: () => null,
      );
      print(response.body);

      if (client != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
      } else {
        print('erro');
      }
    } else {

    }
  }
}
