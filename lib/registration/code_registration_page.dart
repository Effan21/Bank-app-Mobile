import 'dart:convert';
import 'dart:typed_data';
import 'package:bank_app/registration/success_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import '../const.dart';

class CodeRegistration extends StatefulWidget {
  final String phoneNumber;
  final String name;
  final String email;
  final String adresse;
  final String dateNaissance;
  final File? idCardImage;
  final File? userImage;
  final Future<Uint8List?> signatureBytes;

  const CodeRegistration({
    Key? key,
    required this.phoneNumber,
    required this.idCardImage,
    required this.userImage,
    required this.signatureBytes,
    required this.name,
    required this.email,
    required this.adresse,
    required this.dateNaissance,
  }) : super(key: key);

  @override
  State<CodeRegistration> createState() => _CodeRegistrationState();
}

class _CodeRegistrationState extends State<CodeRegistration> {
  late int _code;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> sendData() async {
    print(widget.phoneNumber);
    print(widget.name);
    print(widget.email);
    print(widget.adresse);
    print(widget.dateNaissance);
    print(widget.idCardImage);
    print(widget.userImage);
    print(await widget.signatureBytes);
    print(_code);
    final url = 'http://$ip_server:8000/bank/demandes_ouvertures_comptes/';
    final headers = {'Content-Type': 'multipart/form-data'};

    // Prepare the request body
    final requestBody = http.MultipartRequest('POST', Uri.parse(url));
    requestBody.fields['nom'] = widget.name;
    requestBody.fields['email'] = widget.email;
    requestBody.fields['contact'] = widget.phoneNumber;
    requestBody.fields['date_naissance'] = widget.dateNaissance;
    requestBody.fields['adresse'] = widget.adresse;
    requestBody.files.add(await http.MultipartFile.fromPath(
        'document_pic', widget.idCardImage!.path));
    requestBody.files.add(
        await http.MultipartFile.fromPath('photo', widget.userImage!.path));
    if (widget.signatureBytes != null) {
      final signatureBytes = await widget.signatureBytes;
      if (signatureBytes != null) {
        requestBody.files.add(http.MultipartFile.fromBytes(
          'signature_pic',
          signatureBytes,
          filename: 'signature.png',
        ));
      }
    }
    requestBody.fields['code_secret'] = _code.toString();

    try {
      final response = await http.Response.fromStream(
        await requestBody.send(),
      );

      // Handle the response
      if (response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SuccessPage()),
        );
      } else {
        print('Error: Failed to send data');
        print(response.body);
        print(response.statusCode);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
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
                    'Entrez un code secret',
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
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: screenWidth * 0.025),
                          child: OtpTextField(
                            numberOfFields: 4,
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
                            sendData();
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
                              'Envoyer ma demande',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
