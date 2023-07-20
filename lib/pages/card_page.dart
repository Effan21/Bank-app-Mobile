import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:group_list_view/group_list_view.dart';
import 'package:http/http.dart' as http;

import '../const.dart';
import '../theme/colors.dart';

enum Demandes { creditCard, chequier }

class CardPage extends StatefulWidget {
  final String clientName;
  final int clientId;
  const CardPage({Key? key, required this.clientName, required this.clientId}): super(key: key);

  @override
  _CardPageState createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  List<CarteCredit> creditCards = [];
  List<DemandeCarte> creditCardDemands = [];
  List<DemandeChequier> chequeBookDemands = [];
  String selectedAction = 'Carte de crédit';
  List<String> actions = ['Carte de crédit', 'Chéquier'];
  late int idCompte;
  bool isLoading = true;
  TextEditingController typeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchClientAccount();
    fetchCreditCardDemands();
    fetchChequeBookDemands();
  }

  Future<void> fetchClientAccount() async {
    try {
      // Make an HTTP GET request to the API endpoint
      final response = await http.get(Uri.parse(
          'http://$ip_server:8000/bank/comptes/?client=${widget.clientId}'));

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Parse the JSON data and create a list of Compte objects
        final accountData = jsonDecode(response.body);
        if (accountData.isNotEmpty) {
          final int accountID = accountData[0]['id'];

            idCompte = accountID;

          fetchCreditCards();
        } else {
          // Handle the error response
          print('Failed to fetch client accounts. Status code: ${response.statusCode}');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        // Handle the error response
        print('Failed to fetch client accounts. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors during the API request
      setState(() {
        isLoading = false;
      });
      print('Failed to fetch client accounts. $e');
    }
  }

  Future<void> fetchCreditCards() async {
    try {
      // Make an HTTP GET request to the API endpoint
      final response = await http.get(Uri.parse('http://$ip_server:8000/bank/cartes_credit/?compte=$idCompte'));

      print(idCompte);
      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Parse the JSON data and create a list of CarteCredit objects
        List<CarteCredit> cards = [];
        for (var cardData in jsonData) {
          CarteCredit card = CarteCredit.fromJson(cardData);
          cards.add(card);
        }

        setState(() {
          creditCards = cards;
          isLoading = false;
        });
      } else {
        // Handle the error response
        print('Failed to fetch credit cards. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle any errors during the API request
      print('Error fetching credit cards: $e');
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> fetchCreditCardDemands() async {
    try {
      final response = await http.get(Uri.parse(
          'http://$ip_server:8000/bank/demandes_cartes/?client=${widget.clientId}'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<DemandeCarte> demands = [];
        for (var demandData in jsonData) {
          DemandeCarte demand = DemandeCarte.fromJson(demandData);
          demands.add(demand);
        }

        print('${demands.length} credit card demands fetched');

        setState(() {
          creditCardDemands = demands;
          isLoading = false;
        });
      } else {
        print('Failed to fetch credit card demands. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching credit card demands: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchChequeBookDemands() async {
    try {
      final response = await http.get(Uri.parse(
          'http://$ip_server:8000/bank/demandes_chequiers/?client=${widget.clientId}'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<DemandeChequier> demands = [];
        for (var demandData in jsonData) {
          DemandeChequier demand = DemandeChequier.fromJson(demandData);
          demands.add(demand);
        }
        print('${demands.length} chequier demands fetched');
        setState(() {
          chequeBookDemands = demands;
          isLoading = false;
        });
      } else {
        print('Failed to fetch cheque book demands. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching cheque book demands: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

   Demandes type = Demandes.creditCard;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: isLoading
                ? Center(
              child: CircularProgressIndicator(),
            )
                : ListView.builder(
              itemCount: creditCards.length,
              itemBuilder: (context, index) {
                final creditCard = creditCards[index];
                CardType type;
                if (creditCard.type == 'VISA') {
                  type = CardType.visa;
                } else {
                  type = CardType.mastercard;
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CreditCardWidget(
                    cardNumber: creditCard.numero,
                    expiryDate: creditCard.dateExpiration,
                    cvvCode: creditCard.cvv.toString(),
                    cardHolderName: widget.clientName,
                    isHolderNameVisible: true,
                    bankName: "Max Bank",
                    obscureCardNumber: true,
                    cardType: type,
                    showBackView: false,
                    onCreditCardWidgetChange: (CreditCardBrand) {},
                  ),
                );
              },
            ),
          ),
          isLoading
              ? Center(
            child: CircularProgressIndicator(),
          )
              : Expanded(
            child: GroupListView(
              sectionsCount: 2,
              countOfItemInSection: (section) =>
              section == 0
                  ? creditCardDemands.length
                  : chequeBookDemands.length,
              itemBuilder: (context, index) {
                final section = index.section;
                final itemIndex = index.index;
                if (section == 0) {
                  print("itemIndex: $itemIndex");
                  print("section $section");
                  print("creditCardDemands.length: ${creditCardDemands.length}");
                  return _buildDemandSection(
                    context,
                    "Mes demandes de cartes de crédit",
                    creditCardDemands,
                    itemIndex,
                  );
                } else {

                  print("itemIndex: $itemIndex");
                  print("chequeBookDemands.length: ${chequeBookDemands.length}");
                  return _buildDemandChequeSection(
                    context,
                    "Mes demandes de chéquiers",
                    chequeBookDemands,
                    itemIndex,
                  );
                }
              },
              groupHeaderBuilder: (context, section) {
                  return _buildGroupHeader(
                      context,
                      section == 0 ? "Mes demandes de cartes de crédit" : "Mes demandes de chéquiers");
              },
              separatorBuilder: (context, index) =>
                  SizedBox(height: 8.0),
              sectionSeparatorBuilder: (context, section) =>
                  SizedBox(height: 16.0),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff1b447b),
        onPressed: () {
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
                                      title: const Text('Carte de crédit'),
                                      leading: Radio(
                                        value: Demandes.creditCard,
                                        groupValue: type,
                                        onChanged: (Demandes? value) {
                                          setState(() {
                                            type = value!;
                                          });
                                        },
                                      ),
                                    ),
                                    ListTile(
                                      title: const Text('Chéquier'),
                                      leading: Radio(
                                        value: Demandes.chequier,
                                        groupValue: type,
                                        onChanged: (Demandes? value) {
                                          setState(() {
                                            type = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15),
                                Text(
                                  'Type',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 15),
                                TextField(
                                  controller: typeController,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    hintText: 'Entrez le type',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 15),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: (){

                                    },
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
          // Handle floating action button pressed
          // Implement the logic for creating a new credit card demand
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  Widget _buildGroupHeader(BuildContext context, String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      color: Colors.grey[300],
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        ),
      ),
    );
  }

  Widget _buildDemandSection(BuildContext context, String title, List<DemandeCarte> demands, int itemIndex) {
    final demand = demands[itemIndex];
    return ListTile(
      title: Text('Demande de carte de crédit ${demand.type}'),
      trailing: _buildStatusIcon(demand.status),
      onTap: () {
        // Handle tap on demand
      },
    );
  }

  Widget _buildDemandChequeSection(BuildContext context, String title, List<DemandeChequier> demandes, int itemIndex) {
    final demande = demandes[itemIndex];
    return ListTile(
      title: Text('Demande de chéquier ${demande.type}'),
      trailing: _buildStatusIcon(demande.status),
      onTap: () {
        // Handle tap on demand
      },
    );
  }



  Widget _buildStatusIcon(String status) {
    IconData iconData;
    Color iconColor;

    switch (status) {
      case 'en_attente':
        iconData = Icons.pending;
        iconColor = Colors.orange;
        break;
      case 'approuvee':
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'rejetee':
        iconData = Icons.cancel;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.help_outline;
        iconColor = Colors.grey;
        break;
    }

    return Icon(iconData, color: iconColor);
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
      children: const [
        SizedBox(
          width: 80,
        ),
        Expanded(
          child: Text(
            "Cartes de crédit/Chéquiers",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
        ),
      ],
    ),
  );

}

class CarteCredit {
  final String type;
  final String numero;
  final String dateExpiration;
  final int cvv;
  final int compte;

  CarteCredit({
    required this.type,
    required this.numero,
    required this.dateExpiration,
    required this.cvv,
    required this.compte,
  });

  factory CarteCredit.fromJson(Map<String, dynamic> json) {
    return CarteCredit(
      type: json['type'],
      numero: json['numero'],
      dateExpiration: json['date_expiration'],
      cvv: json['cvv'],
      compte: json['compte'],
    );
  }
}

class DemandeCarte {

  final String type;
  final String status;
  final int client;

  DemandeCarte({
    required this.type,
    required this.status,
    required this.client,
  });

  factory DemandeCarte.fromJson(Map<String, dynamic> json) {
    return DemandeCarte(
      type: json['type'],
      status: json['status'],
      client: json['client'],
    );
  }

}

class DemandeChequier {
  final String type;
  final String status;
  final int client;

  DemandeChequier({
    required this.type,
    required this.status,
    required this.client,
  });

  factory DemandeChequier.fromJson(Map<String, dynamic> json) {
    return DemandeChequier(
      type: json['type'],
      status: json['status'],
      client: json['client'],
    );
  }
}
