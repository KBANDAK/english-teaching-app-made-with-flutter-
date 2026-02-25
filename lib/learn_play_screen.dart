import 'package:flutter/material.dart';

class LearnPlayScreen extends StatelessWidget {
  const LearnPlayScreen({super.key});
  static const routeName = "/learn-play";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Learn & Play")),
      body: const Center(
        child: Text("Learn & Play page (TODO)"),
      ),
    );
  }
}
