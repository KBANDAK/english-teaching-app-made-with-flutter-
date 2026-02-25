import 'package:flutter/material.dart';

class SectionScreen extends StatelessWidget {
  const SectionScreen({
    super.key,
    required this.testId,
    required this.section,
  });

  final String testId;
  final String section; // listening / reading / writing / speaking

  String get title {
    switch (section) {
      case "listening":
        return "Listening";
      case "reading":
        return "Reading";
      case "writing":
        return "Writing";
      case "speaking":
        return "Speaking";
      default:
        return section;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$title • Test $testId")),
      body: Center(
        child: Text(
          "Section: $title\nTest ID: $testId",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
