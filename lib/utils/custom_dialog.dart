


import 'package:flutter/material.dart';

void showCustomDialog(BuildContext context, Widget child) async {
  await showDialog(
  context: context,
  barrierDismissible: true,
  builder: (context) {
    return child ;
  }) ;
}