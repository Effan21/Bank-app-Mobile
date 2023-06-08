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
    return Column(
      children: [
        Initicon(text: user["fname"], size: 55, backgroundColor: user["color"]),
        const SizedBox(
          height: 8,
        ),
        Text(
          user["fname"],
          style: TextStyle(fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}
