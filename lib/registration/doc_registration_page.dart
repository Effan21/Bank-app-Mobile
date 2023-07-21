import 'dart:io';
import 'dart:typed_data';

import 'package:bank_app/registration/code_registration_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';

class DocumentPage extends StatefulWidget {
  final String phoneNumber;
  final String name;
  final String email;
  final String adresse;
  final String dateNaissance;

  const DocumentPage({
    Key? key,
    required this.phoneNumber,
    required this.name,
    required this.email,
    required this.adresse,
    required this.dateNaissance,
  }) : super(key: key);

  @override
  _DocumentPageState createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  File? _idCardImage;
  File? _userImage;
  final picker = ImagePicker();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2.0,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  bool _acceptConditions = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);
    if (pickedFile != null) {
      setState(() {
        final imageFile = File(pickedFile.path);
        if (_idCardImage == null) {
          _idCardImage = imageFile;
        } else if (_userImage == null) {
          _userImage = imageFile;
        }
      });
    }
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: screenHeight * 0.04,
                ),
                const Text(
                  'Inscription',
                  style: TextStyle(fontSize: 28, color: Colors.black),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                const Text(
                  'Vérification de votre identité',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () => _pickImage(ImageSource.camera),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            width: screenWidth * 0.35,
                            height: screenWidth * 0.35,
                            child: _idCardImage != null
                                ? Image.file(_idCardImage!, fit: BoxFit.cover)
                                : Icon(Icons.camera_alt, size: screenWidth * 0.12, color: Colors.grey),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Photo pièce d\'identité',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                    SizedBox(width: screenWidth * 0.10),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () => _pickImage(ImageSource.camera),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            width: screenWidth * 0.35,
                            height: screenWidth * 0.35,
                            child: _userImage != null
                                ? Image.file(_userImage!, fit: BoxFit.cover)
                                : Icon(Icons.camera_alt, size: screenWidth * 0.12, color: Colors.grey),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Photo de vous',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.04),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  width: screenWidth * 0.6,
                  height: screenHeight * 0.15,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignaturePage(signatureController: _signatureController),
                        ),
                      );
                    },
                    child: _signatureController.isNotEmpty
                        ? Icon(
                      Icons.check_circle,
                      size: screenWidth * 0.12,
                      color: Colors.green,
                    )
                        : Icon(
                      Icons.edit,
                      size: screenWidth * 0.12,
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Signez',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                SizedBox(height: screenHeight * 0.04),
                CheckboxListTile(
                  value: _acceptConditions,
                  onChanged: (value) {
                    setState(() {
                      _acceptConditions = value ?? false;
                    });
                  },
                  title: Text(
                    'J\'accepte les conditions générales d\'utilisation',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                SizedBox(height: screenHeight * 0.04),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CodeRegistration(
                            phoneNumber: widget.phoneNumber,
                            name: widget.name,
                            email: widget.email,
                            adresse: widget.adresse,
                            dateNaissance: widget.dateNaissance,
                            userImage: _userImage,
                            idCardImage: _idCardImage,
                            signatureBytes: _signatureController.toPngBytes(),
                          ),
                        ),
                      );
                    },
                    text: 'Continuer',
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignaturePage extends StatefulWidget {
  final SignatureController signatureController;

  const SignaturePage({Key? key, required this.signatureController}) : super(key: key);

  @override
  _SignaturePageState createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  @override
  void dispose() {
    widget.signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 253, 188, 51),
        title: Text('Signature'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Signature(
                controller: widget.signatureController,
                backgroundColor: Colors.white,
                height: 400.0,
              ),
              SizedBox(height: 16.0),
              CustomButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                text: 'Enregistré',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.text,
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
