import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Widget loadingLottie() {
  return Center(
    child: Lottie.asset(
      'assets/loading.json',
      width: 200,
      height: 200,
    ),
  );
}
