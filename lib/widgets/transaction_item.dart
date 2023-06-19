import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../const.dart';

class TransactionItem extends StatefulWidget {
  final int clientId;
  const TransactionItem({Key? key, required this.clientId}) : super(key: key);

  @override
  State<TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  List<Map<String, dynamic>> transactions = [];
  int accountId = 0;

  @override
  void initState() {
    super.initState();
    fetchAccountId();
  }

  Future<void> fetchAccountId() async {
    final response = await http.get(Uri.parse('http://$ip_server:8000/bank/comptes/?client=${widget.clientId}'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      if (responseData.isNotEmpty) {
        setState(() {
          accountId = responseData[0]['id'];
        });
        fetchTransactions();
      } else {
        // Handle empty response
      }
    } else {
      // Handle error response
    }
  }

  Future<void> fetchTransactions() async {
    final response = await http.get(Uri.parse('http://$ip_server:8000/bank/operations/?compte=$accountId'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      setState(() {
        transactions = responseData.cast<Map<String, dynamic>>();
      });
    } else {
      // Handle error response
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: transactions.map((transaction) => _buildTransactionItem(transaction)).toList(),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    String operatorType = transaction['operateur'].toString().toLowerCase();
    String operatorImage;
    if (operatorType.contains('wave')) {
      operatorImage = 'assets/images/wave.png';
    } else if (operatorType.contains('orange')) {
      operatorImage = 'assets/images/orange-money.png';
    } else if (operatorType.contains('mtn')) {
      operatorImage = 'assets/images/MTN.jpeg';
    } else {
      operatorImage = 'assets/images/default.png';
    }

    DateTime date = DateTime.parse(transaction['date']);
    String formattedDate = '${date.day}-${date.month}-${date.year} ${date.hour}:${date.minute}';

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Row(

        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(operatorImage),
          ),
          SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${transaction['operateur']}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 20),
              Text(
                '$formattedDate',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          Spacer(),
          SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${transaction['montant']} FCFA',
                style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 10),
              Icon(
                transaction['type'] == 1 ? Icons.download_rounded : Icons.upload_rounded,
                color: transaction['type'] == 1 ? Colors.green : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
