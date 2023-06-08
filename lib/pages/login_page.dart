import 'package:bank_app/pages/otp_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  final _contactEditingController = TextEditingController();
  var _dialCode = '';

  Future<String> fetchOTP(String phoneNumber) async {
    print(phoneNumber);
    final response =
    await http.get(Uri.parse('http://192.168.1.69:8000/bank/$phoneNumber'));
    print(response);
    if (response.statusCode == 200) {
      final otp = response.body;
      return otp;
    } else {

      throw Exception('Failed to fetch OTP');
    }
  }

  Future<void> clickOnLogin(BuildContext context) async {
    if (_contactEditingController.text.isEmpty) {
      showErrorDialog(context, 'Contact number can\'t be empty.');
    } else {
      try {
         fetchOTP(_contactEditingController.text);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OtpPage(phoneNumber: _contactEditingController.text,)),
        );
      } catch (e) {
        showErrorDialog(context, 'Failed to fetch OTP');
      }
    }
  }

  void showErrorDialog(BuildContext context, String message) {
    final CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: const Text('Error'),
      content: Text('\n$message'),
      actions: <Widget>[
        CupertinoDialogAction(
          isDefaultAction: true,
          child: const Text('Yes'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
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
                  'assets/images/registration.png',
                  height: screenHeight * 0.3,
                  fit: BoxFit.contain,
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                const Text(
                  'Se connecter',
                  style: TextStyle(fontSize: 28, color: Colors.black),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                const Text(
                  'Entrez votre numéro de téléphone pour vous connecter',
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
                        const BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0),
                          blurRadius: 6.0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(16.0)),
                  child: Column(
                    children: [
                      Container(
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
                            SizedBox(
                              width: screenWidth * 0.01,
                            ),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Numéro de téléphone avec l\'indicatif',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 13.5),
                                ),
                                controller: _contactEditingController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [LengthLimitingTextInputFormatter(14)],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      CustomButton(clickOnLogin),
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
}

class CustomButton extends StatelessWidget {
  final clickOnLogin;

  const CustomButton(this.clickOnLogin);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        clickOnLogin(context);
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
          'Continuez',
          style: TextStyle(color: Colors.black, fontSize: 16.0),
        ),
      ),
    );
  }
}
