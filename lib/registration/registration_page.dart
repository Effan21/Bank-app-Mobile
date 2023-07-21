import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../const.dart';
import 'otp_registration.dart';
import 'package:http/http.dart' as http;

class RegistrationPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  Future<void> submitRegistration(BuildContext context) async {
    final response = await http.get(Uri.parse('http://$ip_server:8000/bank/clients/'));

    if (response.statusCode == 200) {
      final clients = jsonDecode(response.body) as List<dynamic>;
      final client = clients.firstWhere(
            (c) => c['contact'] == phoneNumberController.text || c['email'] == emailController.text,
        orElse: () => null,
      );

      if (client != null) {
        await fetchOTP(phoneNumberController.text, context);
      } else {

        print('Error: Client already exists');
      }
    } else {
      print('Error: Failed to fetch client list');
    }
  }

  Future<void> fetchOTP(String phoneNumber, BuildContext context) async {
    try {
      final response = await http.get(Uri.parse('http://$ip_server:8000/bank/$phoneNumber/'));

      if (response.statusCode == 200) {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpRegistration(
              phoneNumber: phoneNumberController.text,
              email: emailController.text,
              adresse: addressController.text,
              dateNaissance: birthdateController.text,
              name: nameController.text,
            ),
          ),
        );

      } else {
        print(phoneNumberController.text);
        print('Error: Failed to fetch OTP');

      }
    } catch (e) {
      print('Error: $e');
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
                    height: screenHeight * 0.02,
                  ),
                  const Text(
                    'Inscription',
                    style: TextStyle(fontSize: 28, color: Colors.black),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  const Text(
                    'Remplissez le formulaire pour créer un compte',
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
                    margin: EdgeInsets.symmetric(horizontal: screenWidth > 600 ? screenWidth * 0.2 : 16),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0),
                          blurRadius: 6.0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: nameController,
                          hintText: 'Nom',
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: emailController,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: addressController,
                          hintText: 'Adresse',
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: birthdateController,
                          hintText: 'Date de naissance',
                          keyboardType: TextInputType.datetime,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),

                          ],
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: phoneNumberController,
                          hintText: 'Numéro de téléphone',
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(14),

                          ],
                        ),
                        const SizedBox(height: 8),
                        CustomButton(
                          onPressed: () => submitRegistration(context),
                          text: 'Continuer',
                          context: context,
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

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.keyboardType,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 45,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 253, 188, 51),
        ),
        borderRadius: BorderRadius.circular(36),
      ),
      child: Row(
        children: [
          SizedBox(width: screenWidth * 0.01),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13.5),
              ),
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final BuildContext context;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.text, required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.all(8),
        height: 45,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 253, 188, 51),
          borderRadius: BorderRadius.circular(36),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(color: Colors.black, fontSize: 16.0),
        ),
      ),
    );
  }
}




