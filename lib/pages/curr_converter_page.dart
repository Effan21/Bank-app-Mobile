import 'dart:collection';

import 'package:bank_app/model/currency_model.dart';
import 'package:bank_app/theme/colors.dart';
import 'package:bank_app/helper/request_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExchangeController extends ChangeNotifier {
  final List<String> currencies = ['USD', 'EUR', 'GBP', 'TRY', 'XOF', 'XAF'];

  late String _baseCurrency = "XOF";
  late String _targetCurrency = "USD";

  double _baseCurrencyValue = 1;
  double _targetCurrencyValue = 1;

  late Future<CurrencyModel> _futureValue =
  RequestHelper().getExchangeRate("XOF", "USD");

  UnmodifiableListView<String> get items {
    return UnmodifiableListView(currencies);
  }

  String get selectedBase {
    return _baseCurrency;
  }

  set selectedBase(final String item) {
    _baseCurrency = item;
    notifyListeners();
  }

  String get selectedTarget {
    return _targetCurrency;
  }

  set selectedTarget(final String item) {
    _targetCurrency = item;
    notifyListeners();
  }

  double get baseValue {
    return _baseCurrencyValue;
  }

  set baseValue(final double item) {
    _baseCurrencyValue = item;
    notifyListeners();
  }

  double get targetValue {
    return _targetCurrencyValue;
  }

  set targetValue(final double item) {
    _targetCurrencyValue = item;
    notifyListeners();
  }

  Future<CurrencyModel> get futureVal {
    return _futureValue;
  }

  set futureVal(final Future<CurrencyModel> item) {
    _futureValue = item;
    notifyListeners();
  }
}

class ExchangePage extends StatelessWidget {
  ExchangePage({Key? key}) : super(key: key);

  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ExchangeController>(
      create: (BuildContext context) => ExchangeController(),
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                _buildHeader(context),
                const SizedBox(
                  height: 35,
                ),
                Expanded(child: buildBody(context)),
              ],
            ),
          ),
        ),
      ),
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
            padding: const EdgeInsets.only(left: 10.0),
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
          const SizedBox(
            width: 60,
          ),
          Expanded(
            child: Text(
              "Convertisseur de devises",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
          ),

        ],
      ),
    );
  }


  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, top: 16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.42,
                  height: MediaQuery.of(context).size.height * 0.16,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Devise de base : ",
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColor.green,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Consumer<ExchangeController>(
                          builder: (
                              final BuildContext context,
                              final ExchangeController exchangeController,
                              final Widget? child,
                              ) =>
                              DropdownButton<String>(
                                items: exchangeController.items
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        value,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                hint: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    "Sélectionnez une devise",
                                  ),
                                ),
                                value: exchangeController.selectedBase,
                                icon: const Padding(
                                  padding: EdgeInsets.only(left: 20, right: 10),
                                  child: Icon(Icons.arrow_drop_down_rounded),
                                ),
                                iconEnabledColor: Colors.black,
                                dropdownColor: Colors.white,
                                underline: Container(),
                                isExpanded: true,
                                onChanged: (value) {
                                  exchangeController.selectedBase = value!;
                                },
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  height: MediaQuery.of(context).size.height * 0.16,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Devise cible : ",
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColor.green,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Consumer<ExchangeController>(
                          builder: (
                              final BuildContext context,
                              final ExchangeController exchangeController,
                              final Widget? child,
                              ) =>
                              DropdownButton<String>(
                                items: exchangeController.items
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        value,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                hint: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    "Sélectionnez une devise",
                                  ),
                                ),
                                value: exchangeController.selectedTarget,
                                icon: const Padding(
                                  padding: EdgeInsets.only(left: 20, right: 10),
                                  child: Icon(Icons.arrow_drop_down_rounded),
                                ),
                                iconEnabledColor: Colors.black,
                                dropdownColor: Colors.white,
                                underline: Container(),
                                isExpanded: true,
                                onChanged: (value) {
                                  exchangeController.selectedTarget = value!;
                                },
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.16,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "Montant :",
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColor.green,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextField(
                        controller: myController,
                        obscureText: false,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '1',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Consumer<ExchangeController>(
                builder: (
                    final BuildContext context,
                    final ExchangeController exchangeController,
                    final Widget? child,
                    ) =>
                    ElevatedButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.change_circle_outlined),
                          SizedBox(
                            width: 5,
                          ),
                          Text('Convertir'),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        fixedSize: Size(
                          MediaQuery.of(context).size.width,
                          MediaQuery.of(context).size.height * 0.08,
                        ),
                      ),
                      onPressed: () {
                        exchangeController.futureVal = RequestHelper()
                            .getExchangeRate(
                            exchangeController.selectedBase,
                            exchangeController.selectedTarget);
                        exchangeController.baseValue =
                            double.parse(myController.text);
                      },
                    ),
              ),
            ),
            const SizedBox(
              height: 55,
            ),
            Consumer<ExchangeController>(
              builder: (
                  final BuildContext context,
                  final ExchangeController exchangeController,
                  final Widget? child,
                  ) =>
                  FutureBuilder<CurrencyModel>(
                    future: exchangeController.futureVal,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.15,
                          decoration: BoxDecoration(
                            color: AppColor.green,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  exchangeController.baseValue.toStringAsFixed(4),
                                ),
                                Text(
                                  (exchangeController.baseValue *
                                      snapshot.data!.value!)
                                      .toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }

                      // By default, show a loading spinner.
                      return const CircularProgressIndicator();
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
