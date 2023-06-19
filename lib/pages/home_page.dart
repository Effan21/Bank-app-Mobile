import 'package:badges/badges.dart';
import 'package:bank_app/data/json.dart';
import 'package:bank_app/pages/ajout_beneficiare_page.dart';
import 'package:bank_app/theme/colors.dart';
import 'package:bank_app/widgets/service_box.dart';
import 'package:bank_app/widgets/avatar_image.dart';
import 'package:bank_app/widgets/balance_card.dart';
import 'package:bank_app/widgets/transaction_item.dart';
import 'package:bank_app/widgets/user_box.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../const.dart';
import 'beneficiaire_page.dart';
import 'menu_page.dart';

enum Operateurs {Orange, MTN, Wave }
enum Factures {CIE, Sodeci}

class HomePage extends StatefulWidget {
  final int clientId;
  final String clientName;
  const HomePage({Key? key, required this.clientId, required this.clientName}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}



class _HomePageState extends State<HomePage> {
  String balance = '0.0';
  String selectedAction = 'Dépot' ;
  List<String> actions = ['Dépot', 'Retrait'];
  String amount = '';
  TextEditingController numFacture = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBalance();
  }

  void handleAmountChange(String value) {
    setState(() {
      amount = value;
    });
  }

 Operateurs noms = Operateurs.Orange;
  Factures types = Factures.CIE;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: _buildBody(),
    );
  }



  void handleSubmit() {
    if (amount.isNotEmpty) {
      if (selectedAction == 'Retrait') {
        // Perform withdrawal logic
        double? withdrawalAmount = double.tryParse(amount);
        if (withdrawalAmount != null) {
          // Update the balance and save the withdrawal transaction
          _performWithdrawal(withdrawalAmount);
        }
      } else if (selectedAction == 'Dépot') {
        // Perform deposit logic
        double? depositAmount = double.tryParse(amount);
        if (depositAmount != null) {
          // Update the balance and save the deposit transaction
          _performDeposit(depositAmount);
        }
      }

      Navigator.pop(context); // Close the modal bottom sheet
    }
  }
  void handleSubmitPayment() {
    if (amount.isNotEmpty) {

        // Perform withdrawal logic
        double? withdrawalAmount = double.tryParse(amount);

          // Update the balance and save the withdrawal transaction
          _performPayment(withdrawalAmount!);

      }

      Navigator.pop(context); // Close the modal bottom sheet
    }




  Future<List<dynamic>> fetchBeneficiaries() async {
    final url = Uri.parse('http://$ip_server:8000/bank/beneficiaires/?client=${widget.clientId}');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data as List<dynamic>;
    } else {
      throw Exception('Failed to fetch beneficiaries');
    }
  }

  Future<void> fetchBalance() async {
    final url = 'http://$ip_server:8000/bank/comptes/?client=${widget.clientId}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      if (data.isNotEmpty) {
        final latestBalance = data.first['solde'].toString();
        setState(() {
          balance = latestBalance;
        });
      }
    } else {
      print('Failed to fetch balance: ${response.statusCode}');
    }
  }


  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(
            height: 25,
          ),
          _buildBalance(),
          const SizedBox(
            height: 35,
          ),
          _buildServices(),
          const SizedBox(
            height: 25,
          ),
          Container(
            padding: EdgeInsets.only(left: 20),
            alignment: Alignment.centerLeft,
            child: Text(
              "Mes bénéficaires",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: _buildRecentUsers(),
          ),
          const SizedBox(
            height: 25,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 15),
            child: _buildTransactionTitle(),
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: _buildTransanctions(),
          ),
        ],
      ),
    );
  }

  _buildHeader() {
    return Container(
      height: 130,
      padding: EdgeInsets.only(left: 20, right: 20, top: 35),
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
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AvatarImage(profile, isSVG: false, width: 35, height: 35),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Salut,",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    widget.clientName, // Display the client's name here
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                  ),
                ],
              ),

            ),
          ),
          const SizedBox(
            width: 15,
          ),
          _buildNotification()
        ],
      ),
    );
  }

  Widget _buildNotification() {
    return Container(
      padding: EdgeInsets.all(5),
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
      child: Badge(

        position: BadgePosition.topEnd(top: -5, end: 2),
        badgeContent: Text(
          '',
          style: TextStyle(color: Colors.white),
        ),
        child: Icon(Icons.notifications_rounded),
      ),
    );
  }

  Widget _buildTransactionTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Mes Transactions",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Today",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        Icon(Icons.expand_more_rounded),
      ],
    );
  }

  Widget _buildBalance() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          BalanceCard(
            balance: "${balance} FCFA",
          ),
        ],
      ),
    );
  }

  Widget _buildServices() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(
          width: 15,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: SingleChildScrollView(
                      child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {


                            return Flex(
                              direction: Axis.vertical,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 20,right: 20,bottom: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      DropdownButton<String>(
                                        value: selectedAction,
                                        onChanged: (String? value) {
                                          setState(() {
                                            selectedAction = value!;
                                          });
                                        },
                                        items: actions.map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                            ),
                                          );
                                        }).toList(),
                                        dropdownColor: Colors.grey[200], // Set the dropdown background color
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ), // Set the style for the dropdown items
                                        icon: Icon(Icons.arrow_drop_down), // Set the dropdown icon
                                      ),
                                      SizedBox(height: 5),
                                      Column(
                                        children: [
                                          ListTile(
                                            title: const Text('Orange Money'),
                                            leading: Radio(
                                              value: Operateurs.Orange,
                                              groupValue: noms,
                                              onChanged: (Operateurs? value) {
                                                setState(() {
                                                  noms = value!;
                                                });
                                              },
                                            ),
                                          ),
                                          ListTile(
                                            title: const Text('MTN Money'),
                                            leading: Radio(
                                              value: Operateurs.MTN,
                                              groupValue: noms,
                                              onChanged: (Operateurs? value) {
                                                setState(() {
                                                  noms = value!;
                                                });
                                              },
                                            ),
                                          ),
                                          ListTile(
                                            title: const Text('Wave'),
                                            leading: Radio(
                                              value: Operateurs.Wave,
                                              groupValue: noms,
                                              onChanged: (Operateurs? value) {
                                                setState(() {
                                                  noms = value!;
                                                });
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 15),
                                      Text(
                                        'Montant',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      TextField(
                                        onChanged: handleAmountChange,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: 'Entrez le montant',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: handleSubmit,
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.all(16),
                                          ),
                                          child: Text(
                                            'Envoyer',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );



                        },
                      ),
                    ),
                  );
                },
              );
            },
            child: const ServiceBox(
              title: "Dépot/Retrait",
              icon: Icons.download_rounded,
              bgColor: AppColor.green,
            ),
          ),

        ),
        const SizedBox(
          width: 15,
        ),
        Expanded(

          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: SingleChildScrollView(
                      child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Flex(
                            direction: Axis.vertical,
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 20,right: 20,bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                   Text('Effectuer un paiement',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                    SizedBox(height: 5),
                                    Column(
                                      children: [
                                        ListTile(
                                          title: const Text('Facture CIE'),
                                          leading: Radio(
                                            value: Factures.CIE,
                                            groupValue: types,
                                            onChanged: (Factures? value) {
                                              setState(() {
                                                types = value!;
                                              });
                                            },
                                          ),
                                        ),
                                        ListTile(
                                          title: const Text('Facture SODECI'),
                                          leading: Radio(
                                            value: Factures.Sodeci,
                                            groupValue: types,
                                            onChanged: (Factures? value) {
                                              setState(() {
                                                types = value!;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextField(
                                      controller: numFacture,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'Entrez le numéro de la facture',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    const Text(
                                      'Montant',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    TextField(
                                      onChanged: handleAmountChange,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'Entrez le montant',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: handleSubmitPayment,
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.all(16),
                                        ),
                                        child: Text(
                                          'Envoyer',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        })));});},
            child: const ServiceBox(
              title: "Payement",
              icon: Icons.payment,
              bgColor: AppColor.yellow,
            ),
          ),
        ),
        const SizedBox(
          width: 15,
        ),
        Expanded(
          child: GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuPage(),
                ),
              );
            },
            child: ServiceBox(
              title: "Plus",
              icon: Icons.widgets_rounded,
              bgColor: AppColor.purple,
            ),
          ),
        ),
        const SizedBox(
          width: 15,
        ),
      ],
    );
  }

  Widget _buildRecentUsers() {
    return FutureBuilder<List<dynamic>>(
      future: fetchBeneficiaries(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          var beneficiaries = snapshot.data!;
          var users = beneficiaries.map(
                (e) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BeneficiairePage(
                          name: e['nom'],
                          number: e['contact'], senderId: widget.clientId,
                        ),
                      ),
                    );
                  },
                  child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: UserBox(user: e),
            ),
                ),
          ).toList();

          return  SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 5),
        scrollDirection: Axis.horizontal,
        child: Row(
        children: [
        Padding(
        padding: const EdgeInsets.only(right: 15),
        child: _buildAddBox(),
        ),
        ...users
        ],
        ));
        } else {
          return Text('No beneficiaries found.');
        }
      },
    );
  }


  Widget _buildAddBox() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AjoutPage(clientId: widget.clientId,),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          "Ajouter",
          style: TextStyle(fontWeight: FontWeight.w500),
        )
      ],
    );
  }

  Widget _buildTransanctions() {
    return Column(
      children: List.generate(
        1,
        (index) => TransactionItem(clientId: widget.clientId,),
      ),
    );
  }
  void _performWithdrawal(double withdrawalAmount) async {
    try {
      // Retrieve the account information of the sender
      final senderResponse = await http.get(Uri.parse('http://$ip_server:8000/bank/comptes/?client=${widget.clientId}'));
      if (senderResponse.statusCode == 200) {
        final accountSenderData = jsonDecode(senderResponse.body) as List<dynamic>;
         print(accountSenderData);
        if (accountSenderData.isNotEmpty) {
          final double senderCurrentBalance = accountSenderData[0]['solde'];
          final int accountId = accountSenderData[0]['id'];

          print(senderCurrentBalance);

          if (senderCurrentBalance >= withdrawalAmount) {
            final double newSenderBalance = senderCurrentBalance - withdrawalAmount;

            // Update the sender's balance
            final Map<String, dynamic> updatedSenderBalance = {
              'solde': newSenderBalance,
            };

            final updateSenderResponse = await http.patch(
              Uri.parse('http://$ip_server:8000/bank/comptes/${widget.clientId}/'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(updatedSenderBalance),
            );

            if (updateSenderResponse.statusCode == 200) {
              // Save the withdrawal transaction
              final Map<String, dynamic> withdrawalTransactionData = {
                'type': 0,
                'montant': withdrawalAmount,
                'compte': accountId,
                'operateur': noms.toString().split('.').last

              };

              print(withdrawalTransactionData);

              final transactionResponse = await http.post(
                Uri.parse('http://$ip_server:8000/bank/operations/'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(withdrawalTransactionData),
              );

              if (transactionResponse.statusCode == 201 || transactionResponse.statusCode == 200) {
                // Withdrawal transaction saved successfully
                print('Withdrawal successful');
              } else {
                // Error occurred while saving the withdrawal transaction
                print(transactionResponse.statusCode);
                print('Failed to save withdrawal transaction');
              }
            } else {
              // Error occurred while updating the sender's balance
              print('Failed to update sender balance');
            }
          } else {
            // Insufficient balance for withdrawal
            print('Insufficient balance for withdrawal');
          }
        } else {
          // Account data not found
          print('Account data not found');
        }
      } else {
        // Error occurred while retrieving the account data
        print('Failed to retrieve account data');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  void _performPayment(double withdrawalAmount) async {
    try {
      // Retrieve the account information of the sender
      final senderResponse = await http.get(Uri.parse('http://$ip_server:8000/bank/comptes/?client=${widget.clientId}'));
      if (senderResponse.statusCode == 200) {
        final accountSenderData = jsonDecode(senderResponse.body) as List<dynamic>;
        print(accountSenderData);
        if (accountSenderData.isNotEmpty) {
          final double senderCurrentBalance = accountSenderData[0]['solde'];
          final int accountId = accountSenderData[0]['id'];

          print(senderCurrentBalance);

          if (senderCurrentBalance >= withdrawalAmount) {
            final double newSenderBalance = senderCurrentBalance - withdrawalAmount;

            // Update the sender's balance
            final Map<String, dynamic> updatedSenderBalance = {
              'solde': newSenderBalance,
            };

            final updateSenderResponse = await http.patch(
              Uri.parse('http://$ip_server:8000/bank/comptes/${widget.clientId}/'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(updatedSenderBalance),
            );

            if (updateSenderResponse.statusCode == 200) {
              // Save the withdrawal transaction
              final Map<String, dynamic> PaymentTransactionData = {
                'montant': withdrawalAmount,
                'type': types.toString().split('.').last,
                'num_facture': double.tryParse(numFacture.text),
                'compte': accountId,
              };

              print(PaymentTransactionData);

              final transactionResponse = await http.post(
                Uri.parse('http://$ip_server:8000/bank/payements/'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(PaymentTransactionData),
              );

              if (transactionResponse.statusCode == 201 || transactionResponse.statusCode == 200) {
                // Withdrawal transaction saved successfully
                print('Withdrawal successful');
              } else {
                // Error occurred while saving the withdrawal transaction
                print(transactionResponse.statusCode);
                print('Failed to save withdrawal transaction');
              }
            } else {
              // Error occurred while updating the sender's balance
              print('Failed to update sender balance');
            }
          } else {
            // Insufficient balance for withdrawal
            print('Insufficient balance for withdrawal');
          }
        } else {
          // Account data not found
          print('Account data not found');
        }
      } else {
        // Error occurred while retrieving the account data
        print('Failed to retrieve account data');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  void _performDeposit(double depositAmount) async {
    try {
      // Retrieve the account information of the sender
      final senderResponse = await http.get(Uri.parse('http://$ip_server:8000/bank/comptes/?client=${widget.clientId}'));
      if (senderResponse.statusCode == 200) {
        final accountSenderData = jsonDecode(senderResponse.body) as List<dynamic>;

        if (accountSenderData.isNotEmpty) {
          final double senderCurrentBalance = accountSenderData[0]['solde'];
          final double newSenderBalance = senderCurrentBalance + depositAmount;
          final int accountId = accountSenderData[0]['id'];

          // Update the sender's balance
          final Map<String, dynamic> updatedSenderBalance = {
            'solde': newSenderBalance,
          };

          final updateSenderResponse = await http.patch(
            Uri.parse('http://$ip_server:8000/bank/comptes/${widget.clientId}/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(updatedSenderBalance),
          );

          if (updateSenderResponse.statusCode == 200) {
            // Save the deposit transaction
            final Map<String, dynamic> depositTransactionData = {
              'type': 1,
              'montant': depositAmount,
              'compte': accountId,
              'operateur': noms.toString().split('.').last

            };

            print(depositTransactionData);

            final transactionResponse = await http.post(
              Uri.parse('http://$ip_server:8000/bank/operations/'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(depositTransactionData),
            );

            if (transactionResponse.statusCode == 201 || transactionResponse.statusCode == 200) {
              // Deposit transaction saved successfully
              print('Deposit successful');
            } else {
              // Error occurred while saving the deposit transaction
              print('Failed to save deposit transaction');
            }
          } else {
            // Error occurred while updating the sender's balance
            print('Failed to update sender balance');
          }
        } else {
          // Account data not found
          print('Account data not found');
        }
      } else {
        // Error occurred while retrieving the account data
        print('Failed to retrieve account data');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
}

