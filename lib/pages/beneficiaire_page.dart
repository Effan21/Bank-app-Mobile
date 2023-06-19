  import 'dart:convert';

  import 'package:bank_app/const.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_initicon/flutter_initicon.dart';
  import 'package:http/http.dart' as http;

  import '../theme/colors.dart';
  class BeneficiairePage extends StatefulWidget {
    final String name;
    final String number;
    final int senderId;

    const BeneficiairePage({Key? key, required this.name, required this.number, required this.senderId}) : super(key: key);

    @override
    State<BeneficiairePage> createState() => _BeneficiairePageState();
  }

  class _BeneficiairePageState extends State<BeneficiairePage> {
  late double balance;
    @override
    void initState() {
      super.initState();

    }
    void _openSendMoneyModal(BuildContext context) {
      String amountToSend = '';
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Envoyer de l\'argent à ${widget.name}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Entrer le montant à envoyer:',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    onChanged: (value) {
                      amountToSend = value;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Montant',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 24),
                  CustomButton(
                    onPressed: () {
                      // TODO: Implement send money logic
                      _sendMoney(context, amountToSend);
                      Navigator.pop(context); // Close the modal bottom sheet
                    },
                    text: 'Envoyer',
                    context: context,
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

  void _sendMoney(BuildContext context, String amountToSend) async {
    final Uri clientsUri = Uri.parse('http://$ip_server:8000/bank/clients/');
    final Uri transactionsUri = Uri.parse('http://$ip_server:8000/bank/virements/');

    try {
      // Check if the beneficiary's number is present in the clients list
      final response = await http.get(clientsUri);
      if (response.statusCode == 200) {
        final clients = jsonDecode(response.body) as List<dynamic>;
        final client = clients.firstWhere(
              (c) => c['contact'] == widget.number,
          orElse: () => null,
        );

        if (client != null) {
          final int beneficiaryId = client['id'];

          // Retrieve the account information of the beneficiary
          final accountResponse = await http.get(Uri.parse('http://$ip_server:8000/bank/comptes/?client=$beneficiaryId'));
          if (accountResponse.statusCode == 200) {
            final accountData = jsonDecode(accountResponse.body) as List<dynamic>;
            if (accountData.isNotEmpty) {
              final double currentBalance = accountData[0]['solde'];
              final int accountId = accountData[0]['id'];

              // Check if the sender has sufficient balance
              final senderResponse = await http.get(Uri.parse('http://$ip_server:8000/bank/comptes/?client=${widget.senderId}'));
              if (senderResponse.statusCode == 200) {
                final senderAccountData = jsonDecode(senderResponse.body) as List<dynamic>;
                if (senderAccountData.isNotEmpty) {
                  final double senderCurrentBalance = senderAccountData[0]['solde'];
                  final int amount = int.tryParse(amountToSend) ?? 0;

                  if (senderCurrentBalance >= amount) {
                    // Calculate the new balances
                    final double newBeneficiaryBalance = currentBalance + amount;
                    final double newSenderBalance = senderCurrentBalance - amount;

                    // Update the balances
                    final Map<String, dynamic> updatedBeneficiaryData = {
                      'solde': newBeneficiaryBalance,
                    };
                    final Map<String, dynamic> updatedSenderData = {
                      'solde': newSenderBalance,
                    };

                    final beneficiaryUpdateResponse = await http.patch(
                      Uri.parse('http://$ip_server:8000/bank/comptes/$beneficiaryId/'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode(updatedBeneficiaryData),
                    );

                    final senderUpdateResponse = await http.patch(
                      Uri.parse('http://$ip_server:8000/bank/comptes/${widget.senderId}/'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode(updatedSenderData),
                    );

                    if (beneficiaryUpdateResponse.statusCode == 200 && senderUpdateResponse.statusCode == 200) {
                      // Save the transaction in the transaction table
                      final Map<String, dynamic> transactionData = {
                        'montant': amount,
                        'client': widget.senderId,
                        'compte_beneficiaire': accountId,
                      };

                      final transactionResponse = await http.post(
                        transactionsUri,
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode(transactionData),
                      );

                      if (transactionResponse.statusCode == 201 || transactionResponse.statusCode == 200) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Success'),
                            content: Text('Amount sent successfully.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context); // Close the modal bottom sheet and return to the previous screen
                                },
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Error occurred while saving the transaction
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Error'),
                            content: Text('Failed to save transaction. Please try again.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    } else {
                      // Error occurred while updating the balances
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Error'),
                          content: Text('Failed to update balances. Please try again.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    // Sender does not have sufficient balance
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Error'),
                        content: Text('Insufficient balance. Please enter a lower amount.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              }
            } else {
              // Error: Empty account data for the beneficiary
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Error'),
                  content: Text('Failed to retrieve beneficiary account information. Please try again.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            }
          }
        } else {
          // Beneficiary not found in the clients list
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Error'),
              content: Text('Beneficiary not found. Please enter a valid beneficiary number.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        // Error occurred while retrieving clients data
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to retrieve clients data. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
    }
  }



  @override
    Widget build(BuildContext context) {
      return Scaffold(

        body:  Container(
          decoration: BoxDecoration(
            color: Colors.white60,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(context),
              SizedBox(height: 45 ),
              Initicon(
                text: widget.name,
                size: 85,
                backgroundColor: Colors.cyan,
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${widget.name}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Numéro: ${widget.number}',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    onPressed: () {
                      _openSendMoneyModal(context);
                    },
                    text: 'Send Money',
                    context: context,
                    color: Colors.orange,
                  ),
                  CustomButton(
                    onPressed: () {
                      // TODO: Implement delete logic

                    },
                    text: 'Delete',
                    context: context,
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),

      );
    }
  }

  class CustomButton extends StatelessWidget {
    final VoidCallback onPressed;
    final String text;
    final BuildContext context;
    final Color color;

    const CustomButton({
      Key? key,
      required this.onPressed,
      required this.text,
      required this.context,
      this.color = Colors.blue,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          primary: color,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
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
                "Informations bénéficiaire",
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
