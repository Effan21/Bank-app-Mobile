
import 'package:badges/badges.dart';
import 'package:bank_app/pages/agencies_location_page.dart';
import 'package:bank_app/pages/curr_converter_page.dart';
import 'package:bank_app/pages/home_page.dart';
import 'package:bank_app/pages/loan_page.dart';
import 'package:bank_app/pages/login_page.dart';
import 'package:bank_app/pages/root_app.dart';
import 'package:flutter/material.dart';
import 'package:bank_app/theme/colors.dart';
import 'package:bank_app/widgets/service_box.dart';

class PublicPage extends StatefulWidget {
  const PublicPage({Key? key}) : super(key: key);

  @override
  State<PublicPage> createState() => _PublicPageState();
}

class _PublicPageState extends State<PublicPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _buildBody(context),
    );
  }
}

Widget _buildBody(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      children: [
        _buildHeader(),
        const SizedBox(
          height: 45,
        ),
        Center(child: _buildServices(context)),
      ],
    ),
  );
}

_buildHeader() {
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
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Salut, Créez un compte ou connectez vous",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  "Pour avoir accès à toutes les fonctionnalités",
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
                    builder: (context) => const RootApp(),
                  ));
              },
              child: ServiceBox(
                title: "Assistance par message",
                icon: Icons.message,
                bgColor: AppColor.appBgColorPrimary,
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
                    builder: (context) => const RootApp(),
                  ));
              },
              child: ServiceBox(
                title: "Ouvrir un compte",
                icon: Icons.create_rounded,
                bgColor: AppColor.purple,
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
                    builder: (context) => LoginPage(),
                  ));
              },
              child: ServiceBox(
                title: "Se connecter",
                icon: Icons.login_rounded,
                bgColor: AppColor.red,
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
        ],
      ),
    ],
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
    child: Icon(Icons.settings, color: Colors.black, size: 30,),
  );
}

