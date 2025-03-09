import 'package:flutter/material.dart';

class MockLoadingIndicator extends StatelessWidget {
  const MockLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class MockErrorMessage extends StatelessWidget {
  final String message;
  const MockErrorMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(message);
  }
}
