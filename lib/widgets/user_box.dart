import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'avatar_image.dart';

class UserBox extends StatelessWidget {
  const UserBox({
    Key? key,
    required this.user,
    this.isSVG = false,
    this.width = 55,
    this.height = 55,
  }) : super(key: key);

  final user;
  final double width;
  final double height;
  final bool isSVG;

  @override
  Widget build(BuildContext context) {
    final beneficiaire = user["nom"] ?? "";
    final random = Random();
    final color = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );

    return Column(
      children: [
        Initicon(
          text: beneficiaire,
          size: 55,
          backgroundColor: color,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          beneficiaire.split(' ')[0],
          style: TextStyle(fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}
