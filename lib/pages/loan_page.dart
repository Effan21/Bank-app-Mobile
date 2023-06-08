import 'package:flutter/material.dart';
import '../theme/colors.dart';

class Loan extends StatefulWidget {
  const Loan({Key? key}) : super(key: key);

  @override
  State<Loan> createState() => _LoanState();
}

class _LoanState extends State<Loan> {
  final TextEditingController _pp = TextEditingController();
  final TextEditingController _dp = TextEditingController();
  final TextEditingController _fa = TextEditingController();
  final TextEditingController _ir = TextEditingController();
  final TextEditingController _t = TextEditingController();
  String _conPP = "";
  String _conDP = "";
  double downPayment = 0;

  void _showDialog(BuildContext? ctx) {
    // Check if the value is not null or empty before showing the dialog
    if (_pp.text.isEmpty ||
        _dp.text.isEmpty ||
        _ir.text.isEmpty ||
        _t.text.isEmpty) {
      // Show the error message snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Rentrez tous les champs"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Calculate the down payment
    double principal = double.parse(_pp.text.replaceAll(',', '')) -
        double.parse(_dp.text.replaceAll(',', ''));

    double monthly = principal / int.parse(_t.text);
    double interest = (principal * double.parse(_ir.text)) / 100;
    double totalInterest = interest * int.parse(_t.text);

    showModalBottomSheet(
      context: ctx!,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text("Montant du prêt"),
                  trailing: Text(_pp.text.replaceAll(',', '')),
                ),
                ListTile(
                  title: const Text("Acompte"),
                  trailing: Text(_dp.text.replaceAll(',', '')),
                ),
                ListTile(
                  title: const Text("Principal"),
                  trailing: Text(principal.toStringAsFixed(0)),
                ),
                ListTile(
                  title: const Text("Taux d'intérêt"),
                  trailing: Text("${_ir.text}%"),
                ),
                ListTile(
                  title: const Text("Prêt à terme"),
                  trailing: Text(_t.text),
                ),
                ListTile(
                  title: const Text("Paiement mensuel"),
                  trailing: Text(monthly.toStringAsFixed(0)),
                ),
                ListTile(
                  title: const Text("Intérêt mensuel"),
                  trailing: Text(interest.toStringAsFixed(0)),
                ),
                ListTile(
                  title: const Text("Intérêt total"),
                  trailing: Text(totalInterest.toStringAsFixed(0)),
                ),
                ListTile(
                  title: const Text("Paiement total"),
                  trailing: Text((monthly + interest).toStringAsFixed(0)),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
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
          const Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Simulateur de crédit",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
          ),
          padding: EdgeInsets.only(bottom: 55, left: 25, right: 25),
          child: ElevatedButton(
            onPressed: () => _showDialog(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.calculate),
                SizedBox(width: 15),
                Text("Simuler"),
              ],
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.purple,
           fixedSize: Size(300, 50),
              textStyle: const TextStyle(fontSize: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),

      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: _pp,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(

                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                      ),
                      floatingLabelStyle: TextStyle(color: Colors.purple),

                      border: OutlineInputBorder(),
                      labelText: 'Montant du prêt',
                      suffixText: "XOF",
                    ),
                    onChanged: (String? string) {
                      if (string!.isEmpty) {
                        // Clear data
                        _dp.clear();
                        _fa.clear();
                        _ir.clear();
                        _t.clear();
                        setState(() {
                          downPayment = 0.0;
                        });
                        return;
                      }
                      _conPP = string.replaceAll(',', '');
                      string = (string.replaceAll(',', ''));
                      _pp.value = TextEditingValue(
                        text: string,
                        selection: TextSelection.collapsed(offset: string.length),
                      );
                      if (_conPP != "" && _conDP != "") {
                        String total =
                        (int.parse(_conPP) - int.parse(_conDP)).toString();
                        _fa.value = TextEditingValue(
                          text: total,
                          selection: TextSelection.collapsed(offset: total.length),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  Text("Acompte (${downPayment.toStringAsFixed(0)}%)"),
                  Slider(
                    activeColor: AppColor.purple,
                    inactiveColor: AppColor.purple.withOpacity(0.2),
                    value: downPayment,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: "${downPayment.toStringAsFixed(0)}%",
                    onChanged: (double? value) {
                      int pp = int.parse(_pp.text.replaceAll(',', ''));
                      int dp = (pp * value! / 100).round();
                      setState(() {
                        downPayment = value;
                        _dp.text = (dp.toString().replaceAll(',', ''));
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _dp,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(

                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                      ),
                      floatingLabelStyle: TextStyle(color: Colors.purple),
                      border: OutlineInputBorder(),
                      labelText: 'Acompte',
                    ),
                    onChanged: (String? string) {
                      if (string!.isEmpty) return;
                      if (int.parse(string.replaceAll(',', '')) > int.parse(_conPP)) {
                        _dp.text = _conPP;
                        return;
                      }
                      _conDP = string.replaceAll(',', '');
                      string = (string.replaceAll(',', ''));
                      _dp.value = TextEditingValue(
                        text: string,
                        selection: TextSelection.collapsed(offset: string.length),
                      );
                      // Check if the down payment is not empty
                      if (_conDP != "") {
                        // Check if the loan amount is not empty
                        if (_conPP != "") {
                          // Calculate the percentage of down payment
                          double dp = int.parse(_conDP) / int.parse(_conPP) * 100;
                          setState(() {
                            downPayment = dp;
                          });
                        } else {
                          // Check if the loan amount is empty
                          String total = (int.parse(_conDP) / downPayment * 100).toString();
                          _conPP = total.replaceAll('.', '');
                          _pp.text = (total.replaceAll('.', ''));
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _ir,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(

                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                      ),
                      floatingLabelStyle: TextStyle(color: Colors.purple),
                      border: OutlineInputBorder(),
                      labelText: 'Taux dintérêt (%)',

                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _t,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(

                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                      ),
                      floatingLabelStyle: TextStyle(color: Colors.purple),
                      border: OutlineInputBorder(),
                      labelText: 'Durée du prêt (Mois)',

                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
