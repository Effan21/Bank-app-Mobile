import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

import '../const.dart';
import '../theme/colors.dart';

class AjoutPage extends StatefulWidget {
  final int clientId;
  const AjoutPage({Key? key, required this.clientId}) : super(key: key);

  @override
  State<AjoutPage> createState() => _AjoutPageState();
}

class _AjoutPageState extends State<AjoutPage> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  final TextEditingController birthdateController = TextEditingController();

  final TextEditingController phoneNumberController = TextEditingController();

  void submitRegistration(BuildContext context) async {
    final String name = nameController.text;
    final String phoneNumber = phoneNumberController.text;




    final Map<String, dynamic> beneficiaryData = {
      'nom': name,
      'contact': phoneNumber,
      'client': widget.clientId,
      // Add other beneficiary fields as needed
    };

    final Uri uri = Uri.parse('http://$ip_server:8000/bank/beneficiaires/');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(beneficiaryData),
      );

      if (response.statusCode == 201) {
        // Beneficiary successfully added
        // Show a success message or navigate to a new screen
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Beneficiary added successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  // Close the dialog and update the beneficiaries UI
                  Navigator.pop(context);


                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Error occurred while adding the beneficiary
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to add beneficiary. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: const Text('An error occurred. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white60,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowColor.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(1, 1), // changes position of shadow
            ),
          ],
          image: DecorationImage(
            image: AssetImage('assets/images/bgcard.png'),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  height: screenHeight - kToolbarHeight - MediaQuery.of(context).padding.top,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.02),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: screenHeight * 0.02),
                            const Text(
                              'Remplissez le formulaire pour ajouter un nouveau bénéficiaire',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.04),
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
                    ],
                  ),
                ),
              ),
            ),
          ],
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
Widget _buildHeader(BuildContext context) {
  return Container(
    height: 100,
    decoration: BoxDecoration(
      color: AppColor.appBgColor,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(40),
        bottomRight: Radius.circular(40),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColor.shadowColor.withOpacity(0.1),
          blurRadius: .5,
          spreadRadius: .5,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 30,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Text(
              "Ajouter un bénéficiaire",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: _buildSettings(),
        ),
      ],
    ),
  );
}

Widget _buildSettings() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 1,
          offset: Offset(1, 1), // changes position of shadow
        ),
      ],
    ),
    child: Icon(
      Icons.settings,
      color: Colors.black,
      size: 30,
    ),
  );
}




