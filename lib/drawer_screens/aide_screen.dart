import 'package:flutter/material.dart';

class AideScreen extends StatefulWidget {
  const AideScreen({super.key});

  @override
  State<AideScreen> createState() => _AideScreenState();
}

class _AideScreenState extends State<AideScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide Page'),
      ),
    );
  }
}