import 'package:flutter/material.dart';
import 'package:bank_app/theme/colors.dart';
import 'package:bank_app/widgets/service_box.dart';

import 'agencies_location_page.dart';
import 'curr_converter_page.dart';
import 'loan_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildBody(context),
    );
  }

}
Widget _buildBody(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      children: [
        _buildHeader(context),
        const SizedBox(
          height: 45,
        ),
        Center(child: _buildServices(context)),
      ],
    ),
  );
}

_buildHeader(BuildContext context) {
  return Container(
    height: 100,
    padding: EdgeInsets.only(left: 20, right: 20, top: 15),
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
        const Expanded(
          child: Text(
            "Plus de services",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
        ),

      ],
    ),
  );
}

Widget _buildServices(BuildContext context) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                // remove the overlay color
                foregroundColor: Colors.black, backgroundColor: Colors.transparent, shadowColor: Colors.transparent, elevation: 0, padding: EdgeInsets.zero, minimumSize: Size(0, 0), alignment: Alignment.center,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExchangePage(),
                    ));
              },
              child: ServiceBox(
                title: "Convertir devises",
                icon: Icons.monetization_on_rounded,
                bgColor: AppColor.green,
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                // remove the overlay color
                foregroundColor: Colors.black, backgroundColor: Colors.transparent, shadowColor: Colors.transparent, elevation: 0, padding: EdgeInsets.zero, minimumSize: Size(0, 0), alignment: Alignment.center,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Loan(),
                    ));
              },
              child: ServiceBox(
                title: "Simuler crédit",
                icon: Icons.calculate_rounded,
                bgColor: AppColor.yellow,
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
        ],
      ),
      const SizedBox( height: 45, ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                // remove the overlay color
                foregroundColor: Colors.black, backgroundColor: Colors.transparent, shadowColor: Colors.transparent, elevation: 0, padding: EdgeInsets.zero, minimumSize: Size(0, 0), alignment: Alignment.center,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationPage(),
                    ));
              },
              child: ServiceBox(
                title: "Voir les agences",
                icon: Icons.location_on_rounded,
                bgColor: AppColor.pink,
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
        ],
      ),
      const SizedBox( height: 45, ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(
            width: 15,
          ),
        ],
      ),
    ],
  );
}